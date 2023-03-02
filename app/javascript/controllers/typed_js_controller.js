import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

// Connects to data-controller="typed-js"
export default class extends Controller {
  connect() {
    new Typed(this.element, {
      strings: ["Discover recommended movies...^1000", "Watch trailers...^1000", "Find popular actors...^1000", ""],
      typeSpeed: 50,
      loop: true
    })
  }
}
