import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-client"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("connected")
    document.addEventListener("turbo:frame-load", this.refocus.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.refocus.bind(this))
  }

  search(event) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      event.target.form.requestSubmit()
    }, 300)
  }

  refocus() {
    this.inputTarget.focus()
  }

}
