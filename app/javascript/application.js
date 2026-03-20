// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"

if ('serviceWorker' in navigator) {
	window.addEventListener('load', () => {
		navigator.serviceWorker.register('/service-worker')
	})
}

let deferredInstallPrompt

window.addEventListener('beforeinstallprompt', (event) => {
	event.preventDefault()
	deferredInstallPrompt = event

	const installButton = document.getElementById('pwa-install-button')
	if (installButton) {
		installButton.classList.remove('hidden')
	}
})

window.addEventListener('appinstalled', () => {
	const installButton = document.getElementById('pwa-install-button')
	if (installButton) {
		installButton.classList.add('hidden')
	}
	deferredInstallPrompt = null
})

document.addEventListener('click', async (event) => {
	const installButton = event.target.closest('#pwa-install-button')
	if (!installButton || !deferredInstallPrompt) return

	deferredInstallPrompt.prompt()
	await deferredInstallPrompt.userChoice
	deferredInstallPrompt = null
	installButton.classList.add('hidden')
})
