// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

window.onload = () => {
  const removeElement = ({target}) => {
    let li = document.getElementById(target.dataset.id)
    let hidden_id = document.getElementById(`${target.dataset.id}_id`)
    li.parentNode.removeChild(hidden_id)
    li.parentNode.removeChild(li)
  }
  Array.from(document.querySelectorAll(".remove-form-field"))
  .forEach(el => {
     el.onclick = (e) => {
       removeElement(e)
     }
  })
  Array.from(document.querySelectorAll(".add-form-field"))
  .forEach(el => {
    el.onclick = ({target: {dataset}}) => {
      let container = document.getElementById(dataset.container)
      let index = dataset.index
      let newRow =
        dataset
        .template
        .replace(/\[0\]/g, `[${index}]`)
        .replace(/_0_/g, `_${index}_`)
        .replace(/_0/g, `_${index}`)
      container.insertAdjacentHTML("beforeend", newRow)
      dataset.index = parseInt(dataset.index) + 1
      Array.from(container.querySelectorAll("a.remove-form-field"))
      .forEach(el => {
        el.onclick = (e) => {
          removeElement(e)
        }
      })
    }
  })
}
