import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textField", "choices" ]
  static values = {
    choices: Array,
    emptyLabel: String,
  }

  connect() {
    this.#updateChoices()
  }

  input() {
    this.#updateChoices()
  }

  chooseElement(e) {
    this.textFieldTarget.value = e.target.id

    this.#updateChoices()
  }

  #updateChoices() {
    let selectedValue = this.textFieldTarget.value
    let valuesToBeShown = this.choicesValue.filter(n => selectedValue !== n)

    this.choicesTarget.innerHTML = ''

    valuesToBeShown.forEach(value => {
      let pTag = document.createElement("p")
      pTag.classList.add("text-xs")

      let linkTag = document.createElement("a")
      linkTag.dataset["action"] = "single-choice-combobox#chooseElement"
      linkTag.classList.add("cursor-pointer")
      linkTag.id = value
      
      let label
      if (value === "") {
        label = this.emptyLabelValue
      } else {
        label = value
      }
      linkTag.text = label

      pTag.appendChild(linkTag)
      this.choicesTarget.appendChild(pTag)
    });
  }
}
