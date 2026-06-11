import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { reversed: Boolean, backLabel: String, frontLabel: String }

  toggle() {
    this.reversedValue = !this.reversedValue
  }

  reversedValueChanged() {
    const back = this.backLabelValue || "Back side"
    const front = this.frontLabelValue || "Front side"
    this.element.textContent = this.reversedValue ? front : back
    this.element.classList.toggle("active", this.reversedValue)

    document.querySelectorAll(".flip-card").forEach((card) => {
      card.classList.toggle("flipped", this.reversedValue)
    })
  }
}
