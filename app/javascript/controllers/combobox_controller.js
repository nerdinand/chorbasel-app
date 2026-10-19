import { Controller } from "@hotwired/stimulus"

// A Windows-ComboBox-style widget: a text field with an attached dropdown list.
//
// Features
//   * select a single value (like a <select>) or multiple values
//   * optional filtering of the list while typing
//   * optional entry of values that are not part of `choices`
//   * full keyboard support (ArrowUp/ArrowDown, Enter, Escape)
//
// Markup
//   <div class="combobox" data-controller="combobox"
//        data-combobox-choices-value='["Apple", "Banana", "Cherry"]'
//        data-combobox-multiselect-value="true">
//     <input type="text" class="combobox__input" autocomplete="off"
//            data-combobox-target="textField" placeholder="Pick fruit…"
//            data-action="click->combobox#fieldClick
//                         input->combobox#input
//                         keydown->combobox#keydown
//                         blur->combobox#blur">
//     <button type="button" class="combobox__toggle"
//             data-combobox-target="toggle" aria-label="Show options"
//             data-action="click->combobox#toggle"></button>
//     <ul class="combobox__menu" data-combobox-target="choices"></ul>
//   </div>
//
// Configuration values
//   choices     Array    options to choose from (default: [])
//   filterable  Boolean  typing filters the list (default: true)
//   multiselect Boolean  several values may be selected; they are serialised
//                        as a comma separated list in the text field
//                        (default: false)
//   allowCustom Boolean  the user may enter values that are not in `choices`
//                        (default: false)
//   emptyLabel  String   label for the "clear selection" entry shown in
//                        single-select mode while a value is selected
//                        (default: "Clear"; "" hides the entry)
//
// The text field is the source of truth: on connect its content is
// deserialised into the current selection, and every change is written back
// as a comma separated list. Values therefore cannot contain commas. When a
// `change` is written programmatically, call the `sync` action afterwards so
// the controller re-reads the field.
export default class extends Controller {
  static targets = ["textField", "toggle", "choices"]

  static values = {
    choices: { type: Array, default: [] },
    filterable: { type: Boolean, default: true },
    multiselect: { type: Boolean, default: false },
    allowCustom: { type: Boolean, default: false },
    emptyLabel: { type: String, default: "Clear" },
  }

  #choices = []
  #keepFocus = null
  #closeOnOutsideMousedown = null

  initialize() {
    this.selected = []
    this.optionElements = []
    this.open = false
    this.query = ""
    this.highlightedIndex = -1
  }

  connect() {
    this.textFieldTarget.setAttribute("role", "combobox")
    this.textFieldTarget.setAttribute("aria-haspopup", "listbox")
    this.textFieldTarget.setAttribute("aria-autocomplete", "list")
    this.textFieldTarget.readOnly = !(this.filterableValue || this.allowCustomValue)

    if (!this.choicesTarget.id) {
      this.choicesTarget.id = `combobox-menu-${Math.random().toString(36).slice(2, 8)}`
    }
    this.textFieldTarget.setAttribute("aria-controls", this.choicesTarget.id)
    this.choicesTarget.setAttribute("role", "listbox")

    // Keep the focus (and with it the uncommitted filter text) on the text
    // field while the user interacts with the menu or the toggle button,
    // otherwise a blur would commit the selection before the click lands.
    this.#keepFocus = (event) => event.preventDefault()
    this.choicesTarget.addEventListener("mousedown", this.#keepFocus)
    if (this.hasToggleTarget) this.toggleTarget.addEventListener("mousedown", this.#keepFocus)

    this.#closeOnOutsideMousedown = (event) => {
      if (!this.element.contains(event.target)) this.#close()
    }
    document.addEventListener("mousedown", this.#closeOnOutsideMousedown)

    this.sync()
  }

  disconnect() {
    this.choicesTarget.removeEventListener("mousedown", this.#keepFocus)
    if (this.hasToggleTarget) this.toggleTarget.removeEventListener("mousedown", this.#keepFocus)
    document.removeEventListener("mousedown", this.#closeOnOutsideMousedown)
  }

  // Re-read the selection from the text field. Call this action after
  // changing the field value programmatically.
  sync() {
    this.selected = this.#deserialize(this.textFieldTarget.value)
    if (!this.multiselectValue) this.selected = this.selected.slice(0, 1)
    this.#choices = this.choicesValue.map((value) => String(value))
    this.#render()
  }

  // -- Actions ----------------------------------------------------------------

  fieldClick() {
    if (!this.open) this.#open()
  }

  toggle() {
    if (this.open) {
      this.#commitQuery()
      this.#reserialize()
      this.#close()
    } else {
      this.query = ""
      this.#open()
    }
  }

  input() {
    this.query = this.#extractQuery()
    this.highlightedIndex = -1
    if (this.filterableValue) this.#open()
    this.#render()
  }

  keydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (!this.open) this.#open()
        this.#highlight(this.highlightedIndex + 1)
        break
      case "ArrowUp":
        if (this.open) {
          event.preventDefault()
          this.#highlight(this.highlightedIndex - 1)
        }
        break
      case "Enter": {
        // Let Enter submit the form when the combobox is fully idle.
        if (!this.open && this.query.trim() === "") break
        event.preventDefault()
        if (this.open && this.highlightedIndex >= 0) {
          this.#chooseHighlighted()
        } else {
          this.#commitQuery()
          this.#reserialize()
          this.#render()
          if (!this.multiselectValue) this.#close()
        }
        break
      }
      case ",":
        // Commas separate values, so they are never typed literally.
        event.preventDefault()
        if (this.multiselectValue && this.#commitQuery()) {
          this.#reserialize()
          this.#render()
        }
        break
      case "Escape":
        event.preventDefault()
        this.#reserialize()
        this.#close()
        break
    }
  }

  blur() {
    this.#commitQuery()
    this.#reserialize()
    this.#close()
  }

  choose(event) {
    const option = event.target.closest("[data-value]")
    if (!option || !this.choicesTarget.contains(option)) return
    this.#toggleChoice(option.dataset.value)
  }

  choicesValueChanged() {
    this.#choices = this.choicesValue.map((value) => String(value))
    this.#render()
  }

  // -- Private ----------------------------------------------------------------

  #toggleChoice(value) {
    if (value === "") {
      // The "clear selection" entry.
      this.selected = []
    } else if (this.multiselectValue) {
      const index = this.selected.indexOf(value)
      if (index >= 0) {
        this.selected.splice(index, 1)
      } else {
        this.selected.push(value)
      }
    } else {
      this.selected = [value]
    }
    this.#reserialize()
    if (!this.multiselectValue) this.#close()
    this.#render()
  }

  #chooseHighlighted() {
    const option = this.optionElements[this.highlightedIndex]
    if (option) this.#toggleChoice(option.dataset.value)
  }

  // Commit the typed filter text as a value, if possible. Returns whether the
  // text could be turned into (or already was) a valid selection.
  #commitQuery() {
    const query = this.query.trim()
    if (query === "") return true

    const exact = this.#matchChoice(query)
    if (exact) {
      this.#add(exact)
      return true
    }
    if (this.allowCustomValue) {
      this.#add(query)
      return true
    }
    // Fall back to the only remaining visible choice, so typing a unique
    // prefix and pressing Enter selects it even without allowCustom.
    const visible = this.#visibleChoices()
    if (visible.length === 1) {
      this.#add(visible[0])
      return true
    }
    return false
  }

  #add(value) {
    if (this.multiselectValue) {
      if (!this.selected.includes(value)) this.selected.push(value)
    } else {
      this.selected = [value]
    }
  }

  #matchChoice(query) {
    const needle = query.toLowerCase()
    return this.#choices.find((choice) => choice.toLowerCase() === needle)
  }

  // Values not present in `choices` (previously entered custom values) are
  // kept visible so they can be inspected and removed.
  #visibleChoices() {
    let values = [
      ...new Set([
        ...this.selected.filter((value) => !this.#choices.includes(value)),
        ...this.#choices,
      ]),
    ]
    if (this.filterableValue && this.query.trim() !== "") {
      const needle = this.query.trim().toLowerCase()
      values = values.filter((value) => value.toLowerCase().includes(needle))
    }
    return values
  }

  // The filter text is the whole field in single-select mode, and the segment
  // after the last comma in multiselect mode.
  #extractQuery() {
    const text = this.textFieldTarget.value
    if (!this.multiselectValue) return text
    const separator = text.lastIndexOf(",")
    return separator === -1 ? text : text.slice(separator + 1)
  }

  #deserialize(value) {
    return value.split(",").map((item) => item.trim()).filter((item) => item !== "")
  }

  #serialize(values) {
    return values.join(", ")
  }

  // Write the canonical selection back to the text field. Also reverts
  // uncommittable filter text on blur/escape.
  #reserialize() {
    this.query = ""
    const serialized = this.#serialize(this.selected)
    if (this.textFieldTarget.value !== serialized) {
      this.textFieldTarget.value = serialized
      this.textFieldTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  #open() {
    if (!this.open) {
      this.open = true
      this.element.classList.add("combobox--open")
      this.textFieldTarget.setAttribute("aria-expanded", "true")
    }
    this.#render()
  }

  #close() {
    this.open = false
    this.highlightedIndex = -1
    this.element.classList.remove("combobox--open")
    this.textFieldTarget.setAttribute("aria-expanded", "false")
  }

  #highlight(index) {
    if (this.optionElements.length === 0) {
      this.highlightedIndex = -1
      return
    }
    if (index < 0) index = this.optionElements.length - 1
    if (index >= this.optionElements.length) index = 0
    this.highlightedIndex = index
    this.#applyHighlight()
  }

  #applyHighlight() {
    this.optionElements.forEach((option, index) => {
      option.classList.toggle("combobox__option--highlighted", index === this.highlightedIndex)
      if (index === this.highlightedIndex) option.scrollIntoView({ block: "nearest" })
    })
  }

  #render() {
    if (!this.hasTextFieldTarget || !this.hasChoicesTarget) return

    const menu = this.choicesTarget
    menu.innerHTML = ""
    this.optionElements = []

    if (!this.multiselectValue && this.selected.length > 0 && this.emptyLabelValue !== "") {
      menu.appendChild(this.#buildOption({
        value: "",
        label: this.emptyLabelValue,
        modifier: "clear",
      }))
    }

    this.#visibleChoices().forEach((value) => {
      menu.appendChild(this.#buildOption({
        value: value,
        label: value,
        selected: this.selected.includes(value),
      }))
    })

    const query = this.query.trim()
    if (this.allowCustomValue && query !== "" && !this.#matchChoice(query)) {
      menu.appendChild(this.#buildOption({
        value: query,
        label: `Add “${query}”`,
        modifier: "custom",
      }))
    }

    if (menu.children.length === 0) {
      const empty = document.createElement("li")
      empty.className = "combobox__empty"
      empty.textContent = "No matches"
      menu.appendChild(empty)
    }

    this.#applyHighlight()
  }

  #buildOption({ value, label, selected = false, modifier = null }) {
    const option = document.createElement("li")
    option.className = "combobox__option"
    if (selected) option.classList.add("combobox__option--selected")
    if (modifier) option.classList.add(`combobox__option--${modifier}`)
    option.dataset.value = value
    option.dataset.action = "click->combobox#choose"
    option.setAttribute("role", "option")
    option.setAttribute("aria-selected", String(selected))

    if (this.multiselectValue) {
      const checkbox = document.createElement("span")
      checkbox.className = "combobox__checkbox"
      if (selected) checkbox.classList.add("combobox__checkbox--checked")
      option.appendChild(checkbox)
    }

    const text = document.createElement("span")
    text.className = "combobox__option-label"
    text.textContent = label
    option.appendChild(text)

    this.optionElements.push(option)
    return option
  }
}