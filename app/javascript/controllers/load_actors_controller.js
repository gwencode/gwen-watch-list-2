import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-actors"
export default class extends Controller {
  static targets = [ "actor", "button" ]

  connect() {
    this.currentPage = 1
    this.perPage = 20
    this.loadPage()
  }

  loadMore(event) {
    event.preventDefault()
    this.currentPage++
    this.loadPage()
  }

  loadPage() {
    const maxActors = this.currentPage * this.perPage
    console.log(maxActors)
    console.log(actorCount)

    if (maxActors >= actorCount) {
      this.updateButton()
    }

    const actors = this.actorTargets
    actors.forEach((actor, index) => {
      if (index < maxActors) {
        actor.classList.remove("d-none")
      }
    })
  }

  updateButton() {
    this.buttonTarget.classList.add("d-none")
  }
}
