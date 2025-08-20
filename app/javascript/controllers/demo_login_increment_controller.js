import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["loginForm"]
    static values = { incrementUrl: String }

    async interceptLogin(event) {
        event.preventDefault()

        try {
            const response = await fetch(this.incrementUrlValue, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": this.csrfToken
                }
            })

            if (response.ok) {
                console.log("Counter incremented successfully")
            }
        }
        catch (error) {
            console.error("Error incrementing counter:", error)
        }
        finally {
            this.loginFormTarget.submit()
        }
    }

    get csrfToken() {
        return document.querySelector('meta[name="csrf-token"]')?.content
    }
}
