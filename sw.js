// Service Worker for ElizAstro PWA
// Caches all assets for full offline support.

const CACHE_NAME = 'elizastro-v1';

const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/css/style.css',
  '/js/ephemeris.js',
  '/js/chart-engine.js',
  '/js/interpretations.js',
  '/js/app.js',
  '/manifest.json',
  '/icons/aries.png',
  '/icons/taurus.png',
  '/icons/gemini.png',
  '/icons/cancer.png',
  '/icons/leo.png',
  '/icons/virgo.png',
  '/icons/libra.png',
  '/icons/scorpio.png',
  '/icons/sagittarius.png',
  '/icons/capricorn.png',
  '/icons/aquarius.png',
  '/icons/pisces.png',
];

// Install: cache all core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

// Activate: clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch: cache-first for local assets, network-first for external requests
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // For same-origin requests, use cache-first strategy
  if (url.origin === self.location.origin) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        if (cachedResponse) {
          // Return cached, but also update cache in background
          const fetchPromise = fetch(event.request).then((networkResponse) => {
            if (networkResponse && networkResponse.status === 200) {
              const responseClone = networkResponse.clone();
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, responseClone);
              });
            }
            return networkResponse;
          }).catch(() => {});
          return cachedResponse;
        }
        return fetch(event.request).then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseClone);
            });
          }
          return networkResponse;
        });
      })
    );
  } else {
    // External requests (e.g., Nominatim): network-first, no caching
    event.respondWith(
      fetch(event.request).catch(() => {
        return new Response('Offline', { status: 503, statusText: 'Offline' });
      })
    );
  }
});
