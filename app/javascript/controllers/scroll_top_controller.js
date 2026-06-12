import { Controller } from "@hotwired/stimulus"

// Floating "back to top" button — always visible; smooth-scrolls to the top on click.
export default class extends Controller {
  scrollUp() {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
}
