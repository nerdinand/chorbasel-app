import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: Number,
    enabled: Boolean,
  }

  connect() {
    if (this.enabledValue) {
      setTimeout(() => { window.location.reload() }, this.intervalValue)
    }
  }
}
