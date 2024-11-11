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
    let value = e.target.innerText

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
      let listItem = document.createElement("li")
      listItem.innerText = value
      listItem.dataset["action"] = "click->combobox#addElement"
      this.choicesTarget.appendChild(listItem)
    });
  }
}
