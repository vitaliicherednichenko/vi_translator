import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, auto: Boolean }

  connect() {
    if (this.autoValue && "IntersectionObserver" in window) {
      this.observer = new IntersectionObserver((entries) => {
        if (entries.some((e) => e.isIntersecting)) this.load()
      }, { rootMargin: "200px" })
      this.observer.observe(this.element)
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  async load() {
    if (this.loading || !this.urlValue) return
    this.loading = true

    const response = await fetch(this.urlValue, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
    if (response.ok) {
      window.Turbo.renderStreamMessage(await response.text())
    } else {
      this.loading = false
    }
  }
}
