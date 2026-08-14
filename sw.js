const CACHE_NAME = 'schengen-guard-anywhere-v2';
const CORE_FILES = [
  './', 'index.html', 'style.css', 'script.js', 'manifest.json', 'icon-192.png', 'icon-512.png',
  'fonts/source-serif-4/source-serif-4-400.woff2', 'fonts/source-serif-4/source-serif-4-400-italic.woff2'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(CORE_FILES))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(names.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n)))
    )
  );
  self.clients.claim();
});

// Network-first: always try to get the freshest version of the app itself,
// falling back to the cached copy only if offline. Trip data is synced to
// Supabase over the network — the app shell above is the only thing precached.
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  // Never cache authenticated requests (Supabase's own auth/REST calls carry an
  // Authorization header). Caching is keyed by URL, not by who's signed in, so on a
  // shared device a cache hit could otherwise hand one user's trip data to the next.
  if (event.request.headers.has('Authorization')) return;
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
