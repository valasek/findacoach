import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["notes"]

    toggle(event) {
        event.preventDefault()
        this.notesTarget.classList.toggle("hidden")
    }

}
