import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-more"
export default class extends Controller {
  static targets = [ "movies", "movie", "button" ]

  connect() {
    this.perPage = 20
    // console.log(pageIndex)
  }

  loadMore(event) {
    event.preventDefault()
    pageIndex++
    // console.log(pageIndex)
    this.loadPage()
  }

  async loadPage() {
    this.maxMovies = pageIndex * this.perPage

    if (pageIndex >= this.pagesCount) {
      this.updateButton()
    }

    const url = `/?page=${pageIndex}`
    const response = await fetch(url)
    const html = await response.text()
    // console.log(html)
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    // console.log(doc)
    // console.log(this.maxMovies)
    const movies = doc.querySelectorAll('[data-load-more-target="movie"]');
    // console.log(movies)
    movies.forEach((node, index) => {
      if (index >= this.maxMovies - this.perPage) {
        this.moviesTarget.insertAdjacentElement('beforeend', movies[index]);
      }
    });
  }

  updateButton() {
    this.buttonTarget.classList.add("d-none")
  }
}

  // const endpoint = `/movies/parse_movies/${this.currentPage}`
  // console.log(endpoint)
  // fetch(endpoint)
  //   .then(response => response.json())
  //   .then(movies => {
  //     console.log(movies)
  //   })

  // fetch(`${apiURL}&page=${this.currentPage}`)
  //   .then(response => response.json())
  //   .then(movies => {
  //     console.log(movies['results'])
  //   })
