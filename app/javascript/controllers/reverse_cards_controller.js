import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { reversed: Boolean }

  toggle() {
    this.reversedValue = !this.reversedValue
  }

  reversedValueChanged() {
    this.element.textContent = this.reversedValue ? "Front side" : "Back side"
    this.element.classList.toggle("active", this.reversedValue)

    document.querySelectorAll(".flip-card").forEach((card) => {
      card.classList.toggle("flipped", this.reversedValue)
    })
  }
}
