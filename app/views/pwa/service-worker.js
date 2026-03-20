const CACHE_VERSION = 'v1'
const CACHE_NAME = `chorbasel-pwa-${CACHE_VERSION}`
const OFFLINE_URL = '/offline.html'

const APP_SHELL_URLS = [OFFLINE_URL]

self.addEventListener('install', (event) => {
	event.waitUntil(
		caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL_URLS))
	)
	self.skipWaiting()
})

self.addEventListener('activate', (event) => {
	event.waitUntil(
		caches.keys().then((cacheNames) => Promise.all(
			cacheNames
				.filter((cacheName) => cacheName.startsWith('chorbasel-pwa-') && cacheName !== CACHE_NAME)
				.map((cacheName) => caches.delete(cacheName))
		))
	)
	self.clients.claim()
})

self.addEventListener('fetch', (event) => {
	if (event.request.method !== 'GET') return

	const requestUrl = new URL(event.request.url)
	if (requestUrl.origin !== self.location.origin) return

	if (event.request.mode === 'navigate') {
		event.respondWith(
			fetch(event.request)
				.then((response) => {
					const responseClone = response.clone()
					caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseClone))
					return response
				})
				.catch(async () => {
					const cachedPage = await caches.match(event.request)
					return cachedPage || caches.match(OFFLINE_URL)
				})
		)
		return
	}

	event.respondWith(
		caches.match(event.request).then((cachedResponse) => {
			const fetchedResponse = fetch(event.request)
				.then((response) => {
					if (!response || response.status !== 200 || response.type !== 'basic') return response

					const responseClone = response.clone()
					caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseClone))
					return response
				})
				.catch(() => cachedResponse)

			return cachedResponse || fetchedResponse
		})
	)
})

// Optional Web Push hooks can be added later if needed.
