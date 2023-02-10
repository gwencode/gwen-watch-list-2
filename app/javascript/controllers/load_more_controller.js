import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-more"
export default class extends Controller {
  static targets = [ "movie", "button" ]

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
    const maxMovies = this.currentPage * this.perPage

    if (maxMovies >= movieCount) {
      this.updateButton()
    }

    const movies = this.movieTargets
    movies.forEach((movie, index) => {
      if (index < maxMovies) {
        movie.classList.remove("d-none")
      }
    })
  }

  updateButton() {
    this.buttonTarget.classList.add("d-none")
  }
}
