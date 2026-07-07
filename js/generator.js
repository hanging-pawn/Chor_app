/**
 * generator.js — Warm-up set generation (FA-001–004)
 *
 * Exports a single function: generateSet(uebungen, options?)
 *
 * Rules:
 *   FA-001  One button press → one fresh set
 *   FA-002  5–6 exercises, strict order: Körper → Atem → Stimme → Abschluss
 *   FA-003  At least one exercise per category; exactly one Abschluss, always last
 *   FA-004  Avoid recently shown exercises when possible (localStorage, graceful fallback)
 */

"use strict";

// ─── Constants ───────────────────────────────────────────────────────────────

const MAIN_CATEGORIES = ["koerper", "atem", "stimme"];
const RECENT_KEY      = "chorapp_recent_ids";
const RECENT_MAX_IDS  = 18; // keep ~3 sets worth of history

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Fisher-Yates partial shuffle — picks n unique items at random from arr.
 * Returns up to arr.length items if n is larger than the pool.
 * Pure function; does not mutate arr.
 *
 * @param {Array}  arr
 * @param {number} n
 * @returns {Array}
 */
function pickRandom(arr, n) {
  const pool   = arr.slice(); // shallow copy
  const count  = Math.min(n, pool.length);
  const result = [];
  for (let i = 0; i < count; i++) {
    const j = i + Math.floor(Math.random() * (pool.length - i));
    [pool[i], pool[j]] = [pool[j], pool[i]];
    result.push(pool[i]);
  }
  return result;
}

/**
 * Filters exercises by category, preferring those not in recentIds (FA-004).
 * Falls back to the full category pool if every exercise has been shown recently.
 *
 * @param {Array}  uebungen
 * @param {string} kategorie
 * @param {Set}    recentIds
 * @returns {Array}
 */
function poolForCategory(uebungen, kategorie, recentIds) {
  const all       = uebungen.filter(u => u.kategorie === kategorie);
  const preferred = all.filter(u => !recentIds.has(u.id));
  return preferred.length > 0 ? preferred : all;
}

// ─── Persistence (FA-004) ────────────────────────────────────────────────────

/**
 * Load recently shown exercise IDs from localStorage.
 * Returns an empty Set when localStorage is unavailable or data is malformed.
 *
 * @returns {Set<string>}
 */
function loadRecentIds() {
  try {
    const raw = localStorage.getItem(RECENT_KEY);
    return new Set(raw ? JSON.parse(raw) : []);
  } catch {
    return new Set();
  }
}

/**
 * Append the IDs from the generated set to the rolling history in localStorage.
 * Silently ignores errors (e.g. private-browsing quota zero).
 *
 * @param {Array} set — array of exercise objects
 */
function saveRecentIds(set) {
  try {
    const prev     = Array.from(loadRecentIds());
    const next     = [...prev, ...set.map(u => u.id)];
    const trimmed  = next.slice(-RECENT_MAX_IDS); // keep only the most recent
    localStorage.setItem(RECENT_KEY, JSON.stringify(trimmed));
  } catch {
    // Not critical — ignore silently
  }
}

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Generate one warm-up set.
 *
 * @param {Array}  uebungen          Full exercise list from uebungen.json
 * @param {object} [options]
 * @param {Set}    [options.recentIds]  Override localStorage lookup (useful for tests)
 * @returns {Array} Ordered array of 5–6 exercise objects
 *
 * @example
 *   const set = generateSet(data.uebungen);
 *   // → [{ id:'koerper-003', kategorie:'koerper', … }, …, { kategorie:'abschluss', … }]
 */
function generateSet(uebungen, options = {}) {
  // FA-004: use injected recentIds in tests, localStorage in production
  const recentIds   = "recentIds" in options ? options.recentIds : loadRecentIds();
  const persistable = !("recentIds" in options);

  // FA-002: total size is 5 or 6
  const totalSize = Math.random() < 0.5 ? 5 : 6;

  // One slot is reserved for Abschluss; distribute the rest among main categories.
  // Minimum one per main category (3 slots), extras go to a random category.
  const mainSlots = totalSize - 1;          // 4 or 5
  const extras    = mainSlots - MAIN_CATEGORIES.length; // 1 or 2

  const counts = { koerper: 1, atem: 1, stimme: 1 };
  for (let i = 0; i < extras; i++) {
    const cat = MAIN_CATEGORIES[Math.floor(Math.random() * MAIN_CATEGORIES.length)];
    counts[cat]++;
  }

  // Collect exercises in FA-002 order
  const result = [];

  for (const kat of MAIN_CATEGORIES) {
    const pool = poolForCategory(uebungen, kat, recentIds);
    result.push(...pickRandom(pool, counts[kat]));
  }

  // FA-003: exactly one Abschluss, always last
  const abschlussPool = poolForCategory(uebungen, "abschluss", recentIds);
  result.push(...pickRandom(abschlussPool, 1));

  // Persist for FA-004 (skipped when running tests)
  if (persistable) {
    saveRecentIds(result);
  }

  return result;
}

// CommonJS export for Node (tests); graceful no-op in the browser
if (typeof module !== "undefined" && module.exports) {
  module.exports = { generateSet, pickRandom, poolForCategory };
}
