import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hideable", "panel", "openIcon", "closeIcon"]

  connect() {
    this.documentClickHandler = this.handleDocumentClick.bind(this)
    document.addEventListener("click", this.documentClickHandler, true)
  }

  disconnect() {
    document.removeEventListener("click", this.documentClickHandler, true)
  }

  showTargets() {
    this.hideableTargets.forEach(el => {
      el.hidden = false
    })
  }

  hideTargets() {
    this.hideableTargets.forEach(el => {
      el.hidden = true
    })
  }

  toggleTargets() {
    if (this.hasPanelTarget) {
      if (this.panelTarget.hidden) {
        this.showPanel()
      } else {
        this.hidePanel()
      }

      return
    }

    this.hideableTargets.forEach((el) => {
      el.hidden = !el.hidden
    })
  }

  handleDocumentClick(event) {
    if (this.element.contains(event.target)) return

    if (this.hasPanelTarget) {
      this.hidePanel()
      return
    }

    this.hideTargets()
  }

  showPanel() {
    this.panelTarget.hidden = false
    if (this.hasOpenIconTarget) this.openIconTarget.hidden = true
    if (this.hasCloseIconTarget) this.closeIconTarget.hidden = false
  }

  hidePanel() {
    this.panelTarget.hidden = true
    if (this.hasOpenIconTarget) this.openIconTarget.hidden = false
    if (this.hasCloseIconTarget) this.closeIconTarget.hidden = true
  }
}
