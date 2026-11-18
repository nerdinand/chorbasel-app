// Load @hotwired/stimulus-loading's eager registration via Vite's import.meta.glob
import { application } from './application'

const controllers = import.meta.glob('./**/*_controller.js', { eager: true })

for (const path in controllers) {
  const identifier = path
    .replace('./', '')
    .replace('/_controller.js', '--')
    .replace('_controller.js', '')
    .replace(/\//g, '--')
    .replace(/_/g, '-')

  if (identifier === 'index') continue

  application.register(identifier, controllers[path].default)
}
