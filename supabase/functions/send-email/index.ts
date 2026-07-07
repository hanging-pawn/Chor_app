/**
 * Supabase Edge Function: send-email (FA-100–104)
 *
 * Sends transactional e-mails via Resend and logs envelope metadata to
 * the email_versand table (FA-104).  Message content is never persisted.
 *
 * Required Supabase Secrets (set via Dashboard → Edge Functions → Secrets):
 *   RESEND_API_KEY   — API key from resend.com
 *   SENDER_EMAIL     — Anja's verified sender address (e.g. anja@example.com)
 *
 * Request body (JSON):
 *   {
 *     to:      string[],   // recipient e-mail addresses
 *     subject: string,
 *     body:    string,     // plain-text body
 *     chor_id: string,     // UUID of the active choir (for logging)
 *     typ:     'rundmail' | 'zahlungserinnerung' | 'probeninfo'
 *   }
 *
 * Response (JSON):
 *   { sent: number, failed: number }
 */

import { serve }        from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ── Constants ─────────────────────────────────────────────────────────────────

const RESEND_API_URL = 'https://api.resend.com/emails'
const RESEND_BATCH_URL = 'https://api.resend.com/emails/batch'

// ── CORS headers (GitHub Pages origin) ───────────────────────────────────────

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ── Handler ───────────────────────────────────────────────────────────────────

serve(async (req: Request): Promise<Response> => {
  // Handle CORS pre-flight.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS })
  }

  // ── Read secrets ────────────────────────────────────────────────────────────

  const RESEND_API_KEY  = Deno.env.get('RESEND_API_KEY')
  const SENDER_EMAIL    = Deno.env.get('SENDER_EMAIL')
  const SUPABASE_URL    = Deno.env.get('SUPABASE_URL')!
  const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

  if (!RESEND_API_KEY || !SENDER_EMAIL) {
    return json({ error: 'Server misconfiguration: RESEND_API_KEY or SENDER_EMAIL missing.' }, 500)
  }

  // ── Authenticate caller ─────────────────────────────────────────────────────

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return json({ error: 'Missing Authorization header.' }, 401)
  }

  // Use the caller's JWT to verify identity and extract user_id.
  const sbUser = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    global: { headers: { Authorization: authHeader } },
  })
  const { data: { user }, error: authError } = await sbUser.auth.getUser()
  if (authError || !user) {
    return json({ error: 'Unauthorized.' }, 401)
  }

  // ── Parse and validate body ─────────────────────────────────────────────────

  let to: string[], subject: string, body: string, chor_id: string, typ: string
  try {
    const payload = await req.json()
    to       = payload.to
    subject  = payload.subject
    body     = payload.body
    chor_id  = payload.chor_id
    typ      = payload.typ
  } catch {
    return json({ error: 'Invalid JSON body.' }, 400)
  }

  const VALID_TYPEN = ['rundmail', 'zahlungserinnerung', 'probeninfo']
  if (
    !Array.isArray(to) || to.length === 0 ||
    typeof subject !== 'string' || subject.trim() === '' ||
    typeof body !== 'string' || body.trim() === '' ||
    typeof chor_id !== 'string' ||
    !VALID_TYPEN.includes(typ)
  ) {
    return json({ error: 'Missing or invalid fields: to, subject, body, chor_id, typ.' }, 400)
  }

  // Sanitize recipient list: remove duplicates and obviously invalid entries.
  const recipients = [...new Set(to.filter(addr => typeof addr === 'string' && addr.includes('@')))]
  if (recipients.length === 0) {
    return json({ error: 'No valid recipient addresses.' }, 400)
  }

  // ── Send via Resend batch API ────────────────────────────────────────────────

  // Resend batch: up to 100 messages per request.
  // Each member gets an individual message (BCC-free; privacy preserved).
  const messages = recipients.map(email => ({
    from:    SENDER_EMAIL,
    to:      [email],
    subject: subject.trim(),
    text:    body.trim(),
  }))

  let sent   = 0
  let failed = 0

  // Split into chunks of 100 (Resend batch limit).
  const CHUNK = 100
  for (let i = 0; i < messages.length; i += CHUNK) {
    const chunk = messages.slice(i, i + CHUNK)
    try {
      const res = await fetch(RESEND_BATCH_URL, {
        method:  'POST',
        headers: {
          'Authorization': `Bearer ${RESEND_API_KEY}`,
          'Content-Type':  'application/json',
        },
        body: JSON.stringify(chunk),
      })

      if (res.ok) {
        sent += chunk.length
      } else {
        const errText = await res.text()
        console.error(`[send-email] Resend batch error (chunk ${i}):`, errText)
        failed += chunk.length
      }
    } catch (err) {
      console.error(`[send-email] Fetch error (chunk ${i}):`, err)
      failed += chunk.length
    }
  }

  // ── Log to email_versand (FA-104) ────────────────────────────────────────────

  // Use the service-role client to bypass RLS on insert (the function acts on
  // behalf of the authenticated user; we set user_id explicitly).
  const sbAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)
  const { error: logError } = await sbAdmin.from('email_versand').insert({
    user_id:           user.id,
    chor_id:           chor_id,
    empfaenger_anzahl: sent,
    betreff:           subject.trim().slice(0, 255),
    typ:               typ,
  })
  if (logError) {
    // Non-fatal: log the error but do not fail the response.
    console.error('[send-email] email_versand insert error:', logError.message)
  }

  return json({ sent, failed })
})

// ── Helpers ───────────────────────────────────────────────────────────────────

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  })
}
