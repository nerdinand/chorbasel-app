// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"

// Chart text and grid lines in the page's colors, so they are readable in light and dark mode.
// Chartkick draws its charts after this module ran, so the defaults apply to all charts.
// When the color scheme changes, the defaults are updated and open charts are redrawn
// (Chart.js caches resolved options, so a plain update would keep the old colors).
const cssColor = (name) => `rgb(${getComputedStyle(document.documentElement).getPropertyValue(`--color-${name}`)})`

const applyChartTheme = () => {
	window.Chart.defaults.color = cssColor('body')
	window.Chart.defaults.borderColor = cssColor('line')
	window.Chartkick.eachChart((chart) => chart.redraw())
}

window.Chart.defaults.font.family = getComputedStyle(document.body).fontFamily
window.Chart.defaults.font.size = 13
applyChartTheme()
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', applyChartTheme)

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
