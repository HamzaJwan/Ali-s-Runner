'use strict';

const COMMIT_HASH = '829fc55';
const CACHE = 'khutuat-v' + COMMIT_HASH;
const CORE_ASSETS = [
  '/index.js',
  '/index.wasm',
  '/index.pck',
  '/manifest.webmanifest',
  '/Cairo-Regular.ttf',
  '/icon-192.png',
  '/icon-512.png'
];

self.addEventListener('install', function(event) {
  event.waitUntil(caches.open(CACHE).then(function(cache) {
    return cache.addAll(CORE_ASSETS);
  }).then(function() {
    return self.skipWaiting();
  }));
});

self.addEventListener('activate', function(event) {
  event.waitUntil(caches.keys().then(function(keys) {
    return Promise.all(keys.filter(function(key) {
      return key !== CACHE;
    }).map(function(key) {
      return caches.delete(key);
    }));
  }).then(function() {
    return self.clients.claim();
  }));
});

self.addEventListener('fetch', function(event) {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin || url.pathname === '/sw.js') return;

  const isDocument = event.request.mode === 'navigate'
    || url.pathname === '/'
    || url.pathname.endsWith('.html');

  if (isDocument) {
    event.respondWith(fetch(event.request).then(function(response) {
      return response;
    }).catch(function() {
      return caches.match('/');
    }));
    return;
  }

  event.respondWith(caches.match(event.request).then(function(cached) {
    if (cached) return cached;
    return fetch(event.request).then(function(response) {
      if (response && response.ok) {
        const copy = response.clone();
        caches.open(CACHE).then(function(cache) { cache.put(event.request, copy); });
      }
      return response;
    });
  }));
});
