// This is a service worker that handles OAuth redirects for Supabase
const CACHE_NAME = 'khangmate-cache-v1';
const urlsToCache = [
    '/',
    '/index.html',
    '/main.dart.js',
    '/manifest.json',
    '/assets/AssetManifest.json',
    '/assets/FontManifest.json',
    '/assets/NOTICES',
    '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
    '/icons/Icon-192.png',
    '/icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => cache.addAll(urlsToCache))
    );
});

self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request)
            .then((response) => response || fetch(event.request))
    );
});