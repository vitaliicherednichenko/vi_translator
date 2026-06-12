// Keeps the page from jumping to the top after a Turbo form submission
// (e.g. deleting a card). The element/form that triggers the visit opts in
// with `data-turbo-preserve-scroll`; we remember the scroll position before
// the new page renders and restore it once Turbo has finished loading.

let preserveScroll = false
let scrollPosition = null

document.addEventListener("turbo:submit-start", (event) => {
  const form = event.detail?.formSubmission?.formElement
  if (form && form.hasAttribute("data-turbo-preserve-scroll")) {
    preserveScroll = true
  }
})

document.addEventListener("turbo:before-render", () => {
  if (preserveScroll) {
    scrollPosition = { left: window.scrollX, top: window.scrollY }
  }
})

// turbo:load fires after the new page is rendered AND Turbo has done its own
// scroll reset, so restoring here reliably wins.
document.addEventListener("turbo:load", () => {
  if (preserveScroll && scrollPosition) {
    window.scrollTo(scrollPosition.left, scrollPosition.top)
  }
  preserveScroll = false
  scrollPosition = null
})
