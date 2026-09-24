import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filter", "contact"]

  connect() {
    if (this.hasContactTarget) {
      this.contactTarget.classList.toggle("hidden", !this.element.querySelector("input[name='booking_request[starts_at]']:checked"))
    }
  }

  disconnect() {
    clearTimeout(this.refreshTimer)
  }

  refresh() {
    clearTimeout(this.refreshTimer)
    this.refreshTimer = setTimeout(() => this.filterTarget.requestSubmit(), 300)
  }

  select() {
    this.contactTarget.classList.remove("hidden")
    this.contactTarget.querySelector("input[name='booking_request[visitor_name]']").focus({ preventScroll: true })
    this.contactTarget.scrollIntoView({ behavior: "instant", block: "start" })
  }
}