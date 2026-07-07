/**
 * generator.test.js — Unit tests for js/generator.js
 *
 * Pure Node.js, no test framework needed.
 * Run with: node 05_Tests/generator.test.js
 *
 * Exit code 0 = all green, 1 = at least one failure.
 */

"use strict";

const { generateSet, pickRandom, poolForCategory } = require("../js/generator");

// ─── Minimal fixture — 2 exercises per category ──────────────────────────────

const UEBUNGEN = [
  { id: "k1", kategorie: "koerper",    titel: "K1" },
  { id: "k2", kategorie: "koerper",    titel: "K2" },
  { id: "k3", kategorie: "koerper",    titel: "K3" },
  { id: "a1", kategorie: "atem",       titel: "A1" },
  { id: "a2", kategorie: "atem",       titel: "A2" },
  { id: "a3", kategorie: "atem",       titel: "A3" },
  { id: "s1", kategorie: "stimme",     titel: "S1" },
  { id: "s2", kategorie: "stimme",     titel: "S2" },
  { id: "s3", kategorie: "stimme",     titel: "S3" },
  { id: "ab1", kategorie: "abschluss", titel: "AB1" },
  { id: "ab2", kategorie: "abschluss", titel: "AB2" },
  { id: "ab3", kategorie: "abschluss", titel: "AB3" },
];

const RUNS = 500; // enough to catch ordering/distribution issues probabilistically

// ─── Tiny assertion helpers ───────────────────────────────────────────────────

let passed = 0;
let failed = 0;

function assert(condition, message) {
  if (condition) {
    passed++;
  } else {
    failed++;
    console.error(`  FAIL  ${message}`);
  }
}

function describe(label, fn) {
  console.log(`\n${label}`);
  fn();
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe("pickRandom", () => {
  const arr = [1, 2, 3, 4, 5];

  assert(pickRandom(arr, 3).length === 3,              "returns exactly n items");
  assert(pickRandom(arr, 10).length === arr.length,    "caps at pool size when n > length");
  assert(pickRandom(arr, 0).length === 0,              "returns empty array for n=0");

  // No duplicates across many calls
  for (let i = 0; i < 100; i++) {
    const picked = pickRandom(arr, 4);
    const unique = new Set(picked).size;
    assert(unique === picked.length, `no duplicates (run ${i})`);
  }

  // Does not mutate source
  const copy = arr.slice();
  pickRandom(arr, 5);
  assert(arr.every((v, i) => v === copy[i]), "does not mutate source array");
});

describe("poolForCategory", () => {
  const empty   = new Set();
  const allIds  = new Set(UEBUNGEN.map(u => u.id));

  const pool = poolForCategory(UEBUNGEN, "koerper", empty);
  assert(pool.every(u => u.kategorie === "koerper"), "returns only the right category");
  assert(pool.length === 3,                          "returns all when none are recent");

  // All marked recent → must still return something (fallback)
  const fallback = poolForCategory(UEBUNGEN, "atem", allIds);
  assert(fallback.length > 0,                        "fallback: never returns empty pool");
  assert(fallback.every(u => u.kategorie === "atem"),"fallback: still filters by category");

  // Partial recent → prefers non-recent
  const partialRecent = new Set(["k1", "k2"]);
  const partial = poolForCategory(UEBUNGEN, "koerper", partialRecent);
  assert(partial.length === 1,                       "prefers the one non-recent exercise");
  assert(partial[0].id === "k3",                     "non-recent exercise is k3");
});

describe("generateSet — single run sanity", () => {
  const set = generateSet(UEBUNGEN, { recentIds: new Set() });

  assert(set.length >= 5 && set.length <= 6,           "length is 5 or 6");
  assert(set[set.length - 1].kategorie === "abschluss","last exercise is Abschluss");

  const cats = set.map(u => u.kategorie);
  assert(cats.includes("koerper"),                     "includes koerper");
  assert(cats.includes("atem"),                        "includes atem");
  assert(cats.includes("stimme"),                      "includes stimme");
  assert(cats.filter(c => c === "abschluss").length === 1, "exactly one Abschluss");

  // No duplicates
  const ids  = set.map(u => u.id);
  assert(new Set(ids).size === ids.length,             "no duplicate exercises");
});

describe(`generateSet — invariants over ${RUNS} runs`, () => {
  let saw5 = false;
  let saw6 = false;

  for (let i = 0; i < RUNS; i++) {
    const set  = generateSet(UEBUNGEN, { recentIds: new Set() });
    const cats = set.map(u => u.kategorie);
    const len  = set.length;

    if (len === 5) saw5 = true;
    if (len === 6) saw6 = true;

    assert(len >= 5 && len <= 6,
      `[run ${i}] length ${len} is not 5 or 6`);

    assert(set[len - 1].kategorie === "abschluss",
      `[run ${i}] last item is not Abschluss (got ${set[len - 1].kategorie})`);

    assert(cats.filter(c => c === "abschluss").length === 1,
      `[run ${i}] more than one Abschluss`);

    assert(cats.includes("koerper"),
      `[run ${i}] missing koerper`);

    assert(cats.includes("atem"),
      `[run ${i}] missing atem`);

    assert(cats.includes("stimme"),
      `[run ${i}] missing stimme`);

    // Ordering: all koerper before all atem; all atem before all stimme
    const lastKoerper = cats.lastIndexOf("koerper");
    const firstAtem   = cats.indexOf("atem");
    const lastAtem    = cats.lastIndexOf("atem");
    const firstStimme = cats.indexOf("stimme");
    const lastStimme  = cats.lastIndexOf("stimme");
    const firstAb     = cats.indexOf("abschluss");

    assert(lastKoerper < firstAtem,
      `[run ${i}] koerper must come before atem (lastKoerper=${lastKoerper}, firstAtem=${firstAtem})`);

    assert(lastAtem < firstStimme,
      `[run ${i}] atem must come before stimme (lastAtem=${lastAtem}, firstStimme=${firstStimme})`);

    assert(lastStimme < firstAb,
      `[run ${i}] stimme must come before abschluss`);

    // No duplicates within a set
    const ids = set.map(u => u.id);
    assert(new Set(ids).size === ids.length,
      `[run ${i}] duplicate exercise IDs: ${ids}`);
  }

  assert(saw5, "generated at least one 5-exercise set across all runs");
  assert(saw6, "generated at least one 6-exercise set across all runs");
});

describe("generateSet — FA-004 avoidance", () => {
  // Mark all koerper exercises as recent; generator must still include one
  const allKoerperRecent = new Set(["k1", "k2", "k3"]);
  for (let i = 0; i < 50; i++) {
    const set  = generateSet(UEBUNGEN, { recentIds: allKoerperRecent });
    const cats = set.map(u => u.kategorie);
    assert(cats.includes("koerper"),
      `[FA-004 run ${i}] must include koerper even when all are recent`);
  }

  // When only one exercise is not recent, it should be picked consistently
  const allButK3 = new Set(["k1", "k2", "a1", "a2", "s1", "s2", "ab1", "ab2"]);
  for (let i = 0; i < 30; i++) {
    const set = generateSet(UEBUNGEN, { recentIds: allButK3 });
    // k3 is the only non-recent koerper; it must appear every time
    const koerperPicked = set.filter(u => u.kategorie === "koerper").map(u => u.id);
    assert(koerperPicked.includes("k3"),
      `[FA-004 run ${i}] k3 should be preferred when others are recent`);
  }
});

// ─── Summary ──────────────────────────────────────────────────────────────────

console.log(`\n${"─".repeat(50)}`);
console.log(`Results: ${passed} passed, ${failed} failed`);

if (failed > 0) {
  process.exitCode = 1;
} else {
  console.log("All tests passed ✓");
}
