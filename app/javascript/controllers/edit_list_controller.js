import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-list"
export default class extends Controller {
  static targets = ["form"]
  displayForm(event) {
    this.formTarget.classList.toggle("d-none")
  }
}
