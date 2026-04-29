// app/javascript/controllers/inline_edit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values  = { url: String }

  edit() {
    this.displayTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  revert() {
    this.inputTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }

  async save() {
    const name = this.inputTarget.value.trim()

    // Nothing changed or empty — just close
    if (!name || name === this.displayTarget.textContent.trim()) {
      return this.revert()
    }

    const token = document.querySelector('meta[name="csrf-token"]').content
    const res   = await fetch(this.urlValue, {
      method:  "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept":       "application/json"
      },
      body: JSON.stringify({ service: { name } })
    })

    if (res.ok) {
      const data = await res.json()
      this.displayTarget.textContent = data.name
    } else {
      // Rollback input to current display value on error
      this.inputTarget.value = this.displayTarget.textContent.trim()
    }

    this.revert()
  }

  handleKeydown(event) {
    if (event.key === "Enter")  { event.preventDefault(); this.save() }
    if (event.key === "Escape") { this.inputTarget.value = this.displayTarget.textContent.trim(); this.revert() }
  }
}
