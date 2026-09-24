import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  static values = { autoSubmit: Boolean }

  connect() {
    const detectedTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone
    const optionExists = Array.from(this.selectTarget.options).some((option) => option.value === detectedTimezone)

    if (this.selectTarget.value === "UTC" && optionExists && detectedTimezone !== this.selectTarget.value) {
      this.selectTarget.value = detectedTimezone
      if (this.autoSubmitValue) {
        this.selectTarget.dispatchEvent(new Event("change", { bubbles: true }))
      }
    }
  }
}