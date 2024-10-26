import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menum"]

    connect() {
        // close the menu when clicking outside
        document.addEventListener("click", this.closeMenu.bind(this))
    }

    disconnect() {
        document.removeEventListener("click", this.closeMenu.bind(this))
    }

    toggle(event) {
        event.stopPropagation()
        this.menumTarget.classList.toggle("hidden")
    }

    closeMenu(event) {
        if (!this.element.contains(event.target)) {
            this.menumTarget.classList.add("hidden")
        }
    }
}