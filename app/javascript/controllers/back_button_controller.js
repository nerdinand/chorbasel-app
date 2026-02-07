import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    if (document.location.pathname == "/") {
      this.buttonTarget.style.display = 'none'
    }
  }

  goBack() {
    history.back()
  }
}
