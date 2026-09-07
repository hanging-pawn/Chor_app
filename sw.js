/**
 * Service Worker der Chorapp — AP-0406, Befund 11.
 *
 * Ziel ist bescheiden und bewusst so gewählt: Die App soll aus dem Homescreen
 * heraus auch ohne Netz starten und das Einsingen erlauben. Das Einsingen läuft
 * rein clientseitig, braucht also nur die App-Datei selbst. Alles, was Daten aus
 * Supabase zieht (Mitglieder, Beiträge, Repertoire), bleibt offline naturgemäss
 * leer — dafür wird hier bewusst nichts vorgegaukelt.
 *
 * Cache-Strategie:
 *   - Seitenaufrufe: Network-First mit Cache als Rückfallebene.
 *   - Statische Dateien und CDN-Bibliotheken: Cache-First.
 *   - Supabase: nie aus dem Cache.
 *
 * Beim Ändern dieser Datei CACHE hochzählen, sonst bleiben alte Einträge liegen.
 */

const CACHE = 'chorapp-v1';

// Lokale Dateien, ohne die die App nicht startet. Schlägt hier etwas fehl, soll
// die Installation scheitern — eine halb gefüllte Offline-Kopie wäre schlechter
// als gar keine, weil sie erst beim Flugmodus auffiele.
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icons/apple-touch-icon.png',
  './icons/icon-192.png',
  './icons/icon-512.png',
];

// CDN-Bibliotheken unter versionierten, unveränderlichen URLs — Cache-First ist
// hier korrekt. Bewusst "best effort": ist eine davon beim Installieren nicht
// erreichbar, soll die App trotzdem offline startfähig werden. Ohne abcjs fehlt
// nur das Notenbild, ohne jsPDF nur der PDF-Export; das Einsingen läuft weiter.
const CDN = [
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js',
  'https://cdn.jsdelivr.net/npm/abcjs@6.6.0/dist/abcjs-basic-min.js',
  'https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js',
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.addAll(APP_SHELL);
    await Promise.allSettled(CDN.map(url => cache.add(url)));
    // Sofort übernehmen: Ein wartender Service Worker würde bedeuten, dass ein
    // Fehler in dieser Datei erst nach dem Schliessen aller Tabs verschwindet.
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const namen = await caches.keys();
    await Promise.all(namen.filter(n => n !== CACHE).map(n => caches.delete(n)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const req = event.request;

  // Nur GET. POST an die Edge Function oder an PostgREST hat im Cache nichts
  // verloren und wird unverändert durchgereicht.
  if (req.method !== 'GET') return;

  let url;
  try {
    url = new URL(req.url);
  } catch {
    return;
  }

  // Supabase (REST, Auth, Storage, Edge Functions) NIE aus dem Cache. Veraltete
  // Mitglieder- oder Beitragsdaten auszuliefern wäre schlimmer als ein sichtbarer
  // Fehler — und ein zwischengespeichertes Auth-Token wäre ein Sicherheitsproblem.
  if (url.hostname.endsWith('.supabase.co')) return;

  // Seitenaufrufe: Network-First. index.html IST die gesamte App; würde sie
  // Cache-First ausgeliefert, sässe die Nutzerin nach jedem Deploy auf einer
  // alten Version fest, bis der Cache irgendwann erneuert wird. Offline greift
  // die zuletzt gespeicherte Kopie.
  if (req.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const netz = await fetch(req);
        const cache = await caches.open(CACHE);
        cache.put('./index.html', netz.clone());
        return netz;
      } catch {
        const cache = await caches.open(CACHE);
        const kopie = await cache.match('./index.html');
        if (kopie) return kopie;
        return new Response(
          '<!doctype html><meta charset="utf-8">'
          + '<p style="font:16px system-ui;padding:2rem">Offline und keine gespeicherte Version vorhanden.</p>',
          { status: 503, headers: { 'Content-Type': 'text/html; charset=utf-8' } },
        );
      }
    })());
    return;
  }

  // Alles Übrige: Cache-First, sonst aus dem Netz und dabei ablegen.
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const treffer = await cache.match(req);
    if (treffer) return treffer;

    try {
      const netz = await fetch(req);
      // Nur Eigenes und die bekannten CDN-Dateien ablegen — sonst füllt sich der
      // Cache mit allem, was die Seite je anfasst.
      if (netz.ok && (url.origin === self.location.origin || CDN.includes(req.url))) {
        cache.put(req, netz.clone());
      }
      return netz;
    } catch {
      return Response.error();
    }
  })());
});
