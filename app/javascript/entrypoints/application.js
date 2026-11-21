// Load the rest of the app (Turbo, Stimulus controllers, chartkick, PWA setup)
import '../application.js'

// Chartkick relies on a global; views (line_chart/column_chart helpers) only emit divs.
// The chartkick/chart.js integration registers the adapter and the components the time
// axis of the attendance chart needs.
import Chartkick from 'chartkick'
import Chart from 'chart.js/auto'
import 'chartkick/chart.js'
window.Chartkick = Chartkick
Chartkick.addAdapter(Chart)

// Chart text and grid lines in the page's colors, so they are readable in light and dark mode.
// Chartkick draws its charts after this module ran, so the defaults apply to all charts.
// When the color scheme changes, the defaults are updated and open charts are redrawn
// (Chart.js caches resolved options, so a plain update would keep the old colors).
const cssColor = (name) => `rgb(${getComputedStyle(document.documentElement).getPropertyValue(`--color-${name}`)})`

const applyChartTheme = () => {
  Chart.defaults.color = cssColor('body')
  Chart.defaults.borderColor = cssColor('line')
  Chartkick.eachChart((chart) => chart.redraw())
}

Chart.defaults.font.family = getComputedStyle(document.body).fontFamily
Chart.defaults.font.size = 13
applyChartTheme()
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', applyChartTheme)
