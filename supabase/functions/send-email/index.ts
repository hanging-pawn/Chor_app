/**
 * Supabase Edge Function: send-email (FA-100–104)
 *
 * Sends transactional e-mails via Resend and logs envelope metadata to
 * the email_versand table (FA-104).  Message content is never persisted.
 *
 * Hardened per AP-0402 (Code Review 2026-08-15, findings 3 and 12):
 *   - Recipients are validated server-side against the caller's own
 *     mitglieder/pianisten rows.  A valid JWT alone no longer turns this
 *     function into an open relay.
 *   - Per-user rate limit over a rolling 24 h window (429 on breach).
 *   - CORS restricted to the GitHub Pages origin.
 *   - Identity is verified with the anon key, not the service-role key.
 *   - subject is stripped of CR/LF before it reaches the mail API.
 *
 * Required Supabase Secrets (Dashboard → Edge Functions → Secrets):
 *   RESEND_API_KEY   — API key from resend.com
 *   SENDER_EMAIL     — verified sender address (see OP-EMAIL-01)
 * SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY are injected
 * by the platform.
 *
 * Request body (JSON):
 *   {
 *     to:      string[],   // recipient e-mail addresses
 *     subject: string,
 *     body:    string,     // plain-text body
 *     chor_id: string,     // UUID of the active choir (must belong to caller)
 *     typ:     'rundmail' | 'zahlungserinnerung' | 'probeninfo'
 *   }
 *
 * Response (JSON):
 *   200 { sent: number, failed: number }
 *   400 { error, unknown?: string[] }   — invalid payload / unknown recipients
 *   401 { error }                       — missing or invalid JWT
 *   403 { error }                       — chor_id does not belong to the caller
 *   429 { error, retry_after_seconds }  — rate limit exceeded
 *   500 { error }                       — misconfiguration or lookup failure
 */

import { serve }        from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ── Constants ─────────────────────────────────────────────────────────────────

const RESEND_BATCH_URL = 'https://api.resend.com/emails/batch'

// Origins allowed to call this function from a browser.  CORS only constrains
// browsers — it is defence in depth, not the access control.  The recipient
// allow-list below is what actually stops abuse from a scripted client.
const ALLOWED_ORIGINS = [
  'https://hanging-pawn.github.io',
]

// Rate limit per authenticated user, rolling window.  Sized for a choir of
// Anja's scale: a rundmail plus individual reminders on a busy day stays well
// under these numbers, while a runaway loop or a stolen token hits the wall.
const RATE_WINDOW_HOURS         = 24
const MAX_SENDS_PER_WINDOW      = 20    // email_versand rows in the window
const MAX_RECIPIENTS_PER_WINDOW = 500   // sum of empfaenger_anzahl in the window
const MAX_RECIPIENTS_PER_REQUEST = 100  // Resend batch limit is 100 per request

const VALID_TYPEN = ['rundmail', 'zahlungserinnerung', 'probeninfo']

// Deliberately stricter than RFC 5322: no comma, semicolon or angle bracket, so
// an address can never smuggle a second recipient or a header into the envelope.
const EMAIL_RE = /^[^\s@,;<>]+@[^\s@,;<>]+\.[^\s@,;<>]+$/

// ── Helpers ───────────────────────────────────────────────────────────────────

function corsHeaders(origin: string | null): Record<string, string> {
  const headers: Record<string, string> = {
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    // The response varies by Origin, so caches must not share it across origins.
    'Vary': 'Origin',
  }
  // No Allow-Origin header at all for anything not on the list — the browser
  // then blocks the response, which is the intended outcome.
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin
  }
  return headers
}

function normaliseEmail(value: unknown): string {
  return typeof value === 'string' ? value.trim().toLowerCase() : ''
}

// ── Handler ───────────────────────────────────────────────────────────────────

serve(async (req: Request): Promise<Response> => {
  const CORS = corsHeaders(req.headers.get('Origin'))

  const json = (data: unknown, status = 200, extra: Record<string, string> = {}): Response =>
    new Response(JSON.stringify(data), {
      status,
      headers: { ...CORS, ...extra, 'Content-Type': 'application/json' },
    })

  // Handle CORS pre-flight.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS })
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed.' }, 405)
  }

  // ── Read secrets ────────────────────────────────────────────────────────────

  const RESEND_API_KEY   = Deno.env.get('RESEND_API_KEY')
  const SENDER_EMAIL     = Deno.env.get('SENDER_EMAIL')
  const SUPABASE_URL     = Deno.env.get('SUPABASE_URL')
  const ANON_KEY         = Deno.env.get('SUPABASE_ANON_KEY')
  const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (!RESEND_API_KEY || !SENDER_EMAIL || !SUPABASE_URL || !ANON_KEY || !SERVICE_ROLE_KEY) {
    console.error('[send-email] Missing secret or platform env var.')
    return json({ error: 'Server misconfiguration.' }, 500)
  }

  // ── Authenticate caller ─────────────────────────────────────────────────────

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return json({ error: 'Missing Authorization header.' }, 401)
  }

  // Identity check and all recipient lookups run on the ANON key with the
  // caller's JWT attached.  Every query below is therefore subject to RLS, so
  // the function physically cannot read another user's members or pianists.
  const sbUser = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth:   { persistSession: false, autoRefreshToken: false },
  })

  const { data: { user }, error: authError } = await sbUser.auth.getUser()
  if (authError || !user) {
    return json({ error: 'Unauthorized.' }, 401)
  }

  // ── Parse and validate body ─────────────────────────────────────────────────

  let to: unknown, subject: unknown, body: unknown, chor_id: unknown, typ: unknown
  try {
    const payload = await req.json()
    to      = payload.to
    subject = payload.subject
    body    = payload.body
    chor_id = payload.chor_id
    typ     = payload.typ
  } catch {
    return json({ error: 'Invalid JSON body.' }, 400)
  }

  if (
    !Array.isArray(to) || to.length === 0 ||
    typeof subject !== 'string' ||
    typeof body    !== 'string' || body.trim() === '' ||
    typeof chor_id !== 'string' || chor_id.trim() === '' ||
    typeof typ     !== 'string' || !VALID_TYPEN.includes(typ)
  ) {
    return json({ error: 'Missing or invalid fields: to, subject, body, chor_id, typ.' }, 400)
  }

  // Strip CR/LF so the subject cannot inject additional mail headers.
  const cleanSubject = subject.replace(/[\r\n]+/g, ' ').trim()
  if (cleanSubject === '') {
    return json({ error: 'Subject must not be empty.' }, 400)
  }
  const cleanBody = body.trim()

  // De-duplicate and normalise the requested recipients.
  const requested = [...new Set(to.map(normaliseEmail).filter(addr => EMAIL_RE.test(addr)))]
  if (requested.length === 0) {
    return json({ error: 'No valid recipient addresses.' }, 400)
  }
  if (requested.length > MAX_RECIPIENTS_PER_REQUEST) {
    return json({
      error: `Too many recipients in one request (max ${MAX_RECIPIENTS_PER_REQUEST}).`,
    }, 400)
  }

  // ── Authorise the choir ─────────────────────────────────────────────────────

  // RLS on choere already limits this to the caller's own choirs, so an empty
  // result means "not yours" just as much as "does not exist".
  const { data: chor, error: chorError } = await sbUser
    .from('choere').select('id').eq('id', chor_id).maybeSingle()

  if (chorError) {
    console.error('[send-email] choere lookup error:', chorError.message)
    return json({ error: 'Could not verify chor_id.' }, 500)
  }
  if (!chor) {
    return json({ error: 'Unknown chor_id, or it does not belong to you.' }, 403)
  }

  // ── Authorise every recipient (AP-0402 step 1) ──────────────────────────────

  const [mitglieder, pianisten] = await Promise.all([
    sbUser.from('mitglieder').select('email').eq('chor_id', chor_id),
    sbUser.from('pianisten').select('email').eq('chor_id', chor_id),
  ])

  if (mitglieder.error || pianisten.error) {
    console.error(
      '[send-email] recipient lookup error:',
      mitglieder.error?.message ?? pianisten.error?.message,
    )
    return json({ error: 'Could not verify recipients.' }, 500)
  }

  const allowed = new Set(
    [...(mitglieder.data ?? []), ...(pianisten.data ?? [])]
      .map(row => normaliseEmail(row.email))
      .filter(Boolean),
  )

  const unknown = requested.filter(addr => !allowed.has(addr))
  if (unknown.length > 0) {
    return json({
      error: 'Recipients not registered for this choir.',
      unknown,
    }, 400)
  }

  // ── Rate limit (AP-0402 step 2) ─────────────────────────────────────────────

  const windowMs   = RATE_WINDOW_HOURS * 60 * 60 * 1000
  const windowStart = new Date(Date.now() - windowMs).toISOString()

  // RLS scopes email_versand to the caller, so this counts only her own sends.
  const { data: recent, error: rateError } = await sbUser
    .from('email_versand').select('empfaenger_anzahl').gte('datum', windowStart)

  if (rateError) {
    // Fail closed: without a usable count we cannot honour the limit.
    console.error('[send-email] rate limit lookup error:', rateError.message)
    return json({ error: 'Could not verify send quota.' }, 500)
  }

  const logRows: Array<{ empfaenger_anzahl: number | null }> = recent ?? []
  const sendsInWindow = logRows.length

  let recipientsInWindow = 0
  for (const row of logRows) {
    recipientsInWindow += row.empfaenger_anzahl ?? 0
  }

  if (
    sendsInWindow >= MAX_SENDS_PER_WINDOW ||
    recipientsInWindow + requested.length > MAX_RECIPIENTS_PER_WINDOW
  ) {
    const retryAfter = String(Math.ceil(windowMs / 1000))
    return json({
      error: `Rate limit exceeded: max ${MAX_SENDS_PER_WINDOW} sends or `
           + `${MAX_RECIPIENTS_PER_WINDOW} recipients per ${RATE_WINDOW_HOURS} h.`,
      retry_after_seconds: Number(retryAfter),
    }, 429, { 'Retry-After': retryAfter })
  }

  // ── Send via Resend batch API ───────────────────────────────────────────────

  // Each recipient gets an individual message (BCC-free; privacy preserved).
  // requested.length is capped at MAX_RECIPIENTS_PER_REQUEST, which equals the
  // Resend batch limit, so a single request is always enough.
  const messages = requested.map(email => ({
    from:    SENDER_EMAIL,
    to:      [email],
    subject: cleanSubject,
    text:    cleanBody,
  }))

  let sent   = 0
  let failed = 0

  try {
    const res = await fetch(RESEND_BATCH_URL, {
      method:  'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type':  'application/json',
      },
      body: JSON.stringify(messages),
    })

    if (res.ok) {
      sent = messages.length
    } else {
      console.error('[send-email] Resend batch error:', await res.text())
      failed = messages.length
    }
  } catch (err) {
    console.error('[send-email] Fetch error:', err)
    failed = messages.length
  }

  // ── Log to email_versand (FA-104) ───────────────────────────────────────────

  // The log row is written with the service-role client so that a future
  // tightening of the insert policy cannot silently break the audit trail.
  // user_id is set explicitly from the verified JWT, never from the request.
  // Every send is logged, including a fully failed one, so the rate limit
  // cannot be sidestepped by triggering failures.
  const sbAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  const { error: logError } = await sbAdmin.from('email_versand').insert({
    user_id:           user.id,
    chor_id:           chor_id,
    empfaenger_anzahl: sent,
    betreff:           cleanSubject.slice(0, 255),
    typ:               typ,
  })
  if (logError) {
    // Non-fatal: log the error but do not fail the response.
    console.error('[send-email] email_versand insert error:', logError.message)
  }

  return json({ sent, failed })
})
