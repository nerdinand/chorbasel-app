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
