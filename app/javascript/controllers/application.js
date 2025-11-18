import { Application } from "@hotwired/stimulus"
import Sortable from '@stimulus-components/sortable'
import Notification from '@stimulus-components/notification'

const application = Application.start()

application.register('sortable', Sortable)
application.register('notification', Notification)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
