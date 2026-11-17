// Load the rest of the app (Turbo, Stimulus controllers, chartkick, PWA setup)
import '../application.js'

// Chartkick relies on a global; views (line_chart/column_chart helpers) only emit divs.
import Chartkick from 'chartkick'
import Chart from 'chart.js/auto'
window.Chartkick = Chartkick
Chartkick.addAdapter(Chart)
