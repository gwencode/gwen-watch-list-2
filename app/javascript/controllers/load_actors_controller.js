import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-actors"
export default class extends Controller {
  static targets = [ "actors", "actor", "button", "loader" ]

  connect() {
    this.perPage = 20
    // console.log(`pageIndex = ${pageIndex}`)
    // console.log(`actorsCount = ${actorsCount}`)
    // console.log(`Query = ${query}`)
    if (actorsCount < 20) {
      this.updateButton()
    }
  }

  loadMore(event) {
    event.preventDefault()
    pageIndex++
    this.showLoader();
    this.loadPage()
  }

  async loadPage() {
    const maxActors = pageIndex * this.perPage
    // console.log(`pageIndex = ${pageIndex}`)
    // console.log(`actorsCount = ${actorsCount}`)
    // console.log(`maxActors = ${maxActors}`)
    // console.log(`Query = ${query}`)

    if (maxActors >= actorsCount) {
      this.updateButton()
    }

    const url =`/actors?page=${pageIndex}&query=${query}`
    const response = await fetch(url)
    // console.log(response)
    const actors = await response.json()
    this.insertActors(actors);
    this.hideLoader();
  }

  insertActors(actors) {
    // console.log(actors)
    const html = actors.map(actor => {
    return `<div data-load-actors-target="actor">
              <a class="text-decoration-none" href="/actors/${actor.id}">
                <div class="actor">
                  <div class="card-movie">
                    <img src="${actor.picture_url}">
                  </div>
                  <h5 class="py-3">${actor.name}</h5>
                </div>
              </a>
            </div>`;
    }).join('');
    this.actorsTarget.insertAdjacentHTML('beforeend', html);
  }

  updateButton() {
    this.buttonTarget.classList.add("d-none")
  }

  showLoader() {
    this.loaderTarget.classList.remove("d-none")
    this.buttonTarget.setAttribute('disabled', 'disabled');
  }

  hideLoader() {
    this.loaderTarget.classList.add('d-none');
    this.buttonTarget.removeAttribute('disabled');
  }
}
