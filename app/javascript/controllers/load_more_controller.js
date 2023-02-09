import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-more"
export default class extends Controller {
  static targets = [ "movie", "button" ]

  connect() {
    this.currentPage = 1
    this.perPage = 20
    // this.maxPages = Math.ceil(this.moviesTarget.dataset.total / this.perPage)
    // this.updateButton()
    this.loadPage()
  }

  loadMore(event) {
    event.preventDefault()
    this.currentPage++
    // this.updateButton()
    this.loadPage()
  }

  // updateButton() {
  //   if (this.currentPage >= this.maxPages) {
  //     this.buttonTarget.classList.add("d-none")
  //   }
  // }

  loadPage() {
    const maxMovies = this.currentPage * this.perPage
    const movies = this.movieTargets
    movies.forEach((movie, index) => {
      if (index < maxMovies) {
        movie.classList.remove("d-none")
      }
    })
  }
}
