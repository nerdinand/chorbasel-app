import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textField", "choices" ]
  static values = {
    choices: Array
  }

  connect() {
    this.#updateChoices()
  }

  input() {
    this.#updateChoices()
  }

  addElement(e) {
    let value = e.target.id

    let oldValues = this.#deserializeTextFieldValue(this.textFieldTarget.value)
    let newValues = oldValues.concat(value)
    this.textFieldTarget.value = this.#serializeTextFieldValue(newValues)

    this.#updateChoices()
  }

  #deserializeTextFieldValue(value) {
    return value.split(",").map(e => e.trim()).filter(e => e != "")
  }

  #serializeTextFieldValue(values) {
    return values.join(", ")
  }

  #updateChoices() {
    let selectedValues = this.#deserializeTextFieldValue(this.textFieldTarget.value)
    let valuesToBeShown = this.choicesValue.filter(n => !selectedValues.includes(n))

    this.choicesTarget.innerHTML = ''

    valuesToBeShown.forEach(value => {
      let pTag = document.createElement("p")
      pTag.classList.add("text-xs")

      let labelTag = document.createElement("label")
      labelTag.htmlFor = value

      let checkboxTag = document.createElement("input")
      checkboxTag.type = "checkbox"
      checkboxTag.dataset["action"] = "combobox#addElement"
      checkboxTag.id = value

      labelTag.appendChild(checkboxTag)
      labelTag.appendChild(document.createTextNode(value))

      pTag.appendChild(labelTag)
      this.choicesTarget.appendChild(pTag)
    });
  }
}
