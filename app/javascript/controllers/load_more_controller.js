import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-more"
export default class extends Controller {
  static targets = [ "movies", "movie", "button", "loader" ]

  connect() {
    this.perPage = 20
    // console.log(`Page index = ${pageIndex}`)
    // console.log(`Query = ${query}`)
    // console.log(`Genre = ${genre}`)
    // console.log(`moviesCount = ${moviesCount}`)
    if (moviesCount <= 20) {
      this.updateButton()
    }
  }

  loadMore(event) {
    event.preventDefault()
    pageIndex++
    // console.log(`Page index = ${pageIndex}`)
    // console.log(`Query = ${query}`)
    // console.log(`Genre = ${genre}`)
    // console.log(`moviesCount = ${moviesCount}`)
    this.showLoader();
    this.loadPage()
  }

  loadPage() {
    this.maxMovies = pageIndex * this.perPage
    // console.log(`Max movies = ${this.maxMovies}`)

    if (moviesCount <= this.maxMovies) {
      // console.log("Hide button when no more movies in filters")
      this.updateButton()
    }

    if (pageIndex == 500) {
      // console.log("Hide button when max pages of the API is reached")
      this.updateButton()
    }

    const url =`/?query=${query}&genre=${genre}&page=${pageIndex}`
    fetch(url)
    .then((response) => {
      // console.log(response);
      return response.json();
    })
    .then((movies) => {
      this.insertMovies(movies);
      this.hideLoader();
    })
    .catch((error) => console.log(error));
  }

    insertMovies(movies) {
      // console.log(movies)
      const html = movies.map(movie => {
        return `<div data-load-more-target="movie">
                  <a class="text-decoration-none" href="/movies/${movie.id}">
                    <div class="card-movie">
                      <img src="${movie.poster_url}">
                    </div>
                  </a>
                </div>`;
      }).join('');
      this.moviesTarget.insertAdjacentHTML('beforeend', html);
    }

    updateButton() {
      this.buttonTarget.classList.add("d-none")
    }

    showLoader() {
      this.loaderTarget.classList.remove('d-none');
      this.buttonTarget.setAttribute('disabled', 'disabled');
    }

    hideLoader() {
      this.loaderTarget.classList.add('d-none');
      this.buttonTarget.removeAttribute('disabled');
    }

    // scrollToMovies(position) {
    //   // const firstMovie = this.movieTargets[position];
    //   console.log("Scrolling to movies with getBouding")
    //   // firstMovie.scrollIntoView({ behavior: "smooth", block: "end"});
    //   const firstMovie = this.movieTargets[position];
    //   const { top } = firstMovie.getBoundingClientRect();
    //   window.scrollTo({
    //     top: window.scrollY + top,
    //     behavior: 'smooth'
    //   });

    // scroll() {
    //   console.log("Scrolling to movies with window.innerHeight")
    //   const scrollHeight = window.innerHeight * 0.8;
    //   window.scrollTo({
    //     top: scrollHeight,
    //     behavior: 'smooth'
    //   });
    // }
  }

  // const url = `/?page=${pageIndex}`
  // const response = await fetch(url)
  // const html = await response.text()
  // console.log(html)
  // const parser = new DOMParser();
  // const doc = parser.parseFromString(html, 'text/html');
  // // console.log(doc)
  // // console.log(this.maxMovies)
  // const movies = doc.querySelectorAll('[data-load-more-target="movie"]');
  // // console.log(movies)
  // movies.forEach((node, index) => {
  //   if (index >= this.maxMovies - this.perPage) {
  //     this.moviesTarget.insertAdjacentElement('beforeend', movies[index]);
  //   }
  // });

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
