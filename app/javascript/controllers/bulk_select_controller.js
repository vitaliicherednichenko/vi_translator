import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "all", "submit", "count"]
  static values = { url: String, confirm: String }

  update() {
    const checked = this.checkedItems
    if (this.hasCountTarget) this.countTarget.textContent = checked.length
    if (this.hasSubmitTarget) this.submitTarget.disabled = checked.length === 0
    if (this.hasAllTarget) {
      this.allTarget.checked = checked.length > 0 && checked.length === this.itemTargets.length
      this.allTarget.indeterminate = checked.length > 0 && checked.length < this.itemTargets.length
    }
  }

  toggleAll() {
    this.itemTargets.forEach((cb) => (cb.checked = this.allTarget.checked))
    this.update()
  }

  destroy(event) {
    event.preventDefault()
    const ids = this.checkedItems.map((cb) => cb.value)
    if (ids.length === 0) return
    if (this.confirmValue && !window.confirm(this.confirmValue)) return

    const form = document.createElement("form")
    form.method = "post"
    form.action = this.urlValue
    form.hidden = true
    form.setAttribute("data-turbo-preserve-scroll", "")

    this.addInput(form, "_method", "delete")
    this.addInput(form, this.csrfParam, this.csrfToken)
    ids.forEach((id) => this.addInput(form, "card_ids[]", id))

    document.body.appendChild(form)
    form.requestSubmit()
  }

  get checkedItems() {
    return this.itemTargets.filter((cb) => cb.checked)
  }

  addInput(form, name, value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    form.appendChild(input)
  }

  get csrfParam() {
    return document.querySelector("meta[name=csrf-param]")?.content || "authenticity_token"
  }

  get csrfToken() {
    return document.querySelector("meta[name=csrf-token]")?.content || ""
  }
}
