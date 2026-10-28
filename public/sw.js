// Sahhef | Journal it - Service Worker for PWA installation
const CACHE_NAME = 'sahhef-pwa-v1';

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    self.clients.claim().then(() => {
      return caches.keys().then((keys) => {
        return Promise.all(
          keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
        );
      });
    })
  );
});

self.addEventListener('fetch', (event) => {
  // Pass-through fetch handler satisfying Chrome PWA install criteria
  if (event.request.method === 'GET' && event.request.url.startsWith(self.location.origin)) {
    event.respondWith(
      fetch(event.request).catch(async () => {
        const cached = await caches.match(event.request);
        if (cached) return cached;
        return new Response('Offline', { status: 503, statusText: 'Offline' });
      })
    );
  }
});
