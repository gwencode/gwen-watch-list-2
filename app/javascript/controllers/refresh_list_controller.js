// import { Controller } from "@hotwired/stimulus"

// // Connects to data-controller="refresh-list"
// export default class extends Controller {
//   static targets = [ "form", "list", "searchInput" ]

//   connect() {
//     // console.log("controller connected")
//     // console.log("this.element = ", this.element)
//     // console.log("this.formTarget = ", this.formTarget)
//     // console.log("this.listTarget = ", this.listTarget)
//     // console.log("this.searchInputTarget = ", this.searchInputTarget)
//   }

//   update() {
//     const url = `${this.formTarget.action}?query=${this.searchInputTarget.value}`
//     // console.log("url = ", url)
//     fetch(url, {
//       headers: { 'Accept': 'application/json' }
//       // body: new FormData(this.listTarget)
//     })
//       .then(response => response.json())
//       .then((data) => {
//         // console.log("data list = ", data.list)
//         this.listTarget.outerHTML = data.list;
//       })
//   }
// }
