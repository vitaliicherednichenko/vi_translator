import { Controller } from "@hotwired/stimulus"

// Toggles a "flipped" class on the card so CSS can run the 3D flip.
export default class extends Controller {
  toggle() {
    this.element.classList.toggle("flipped")
  }

  toggleKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.toggle()
    }
  }
}
