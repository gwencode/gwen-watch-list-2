import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert"
export default class extends Controller {
  static targets = ["alert"]
  connect() {
  }
  close() {
    this.alertTarget.classList.add("d-none")
  }
}
