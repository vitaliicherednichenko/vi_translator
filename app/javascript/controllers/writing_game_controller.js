import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "play", "card", "prompt", "srcBadge", "tgtBadge", "input", "feedback",
    "progress", "score", "done", "doneCount", "doneScore"
  ]
  static values = {
    cards: Array,
    correctText: String,
    answerPrefix: String
  }

  connect() {
    this.start()
  }

  start() {
    this.deck = this.shuffle([...this.cardsValue])
    this.position = 0
    this.correct = 0
    if (this.deck.length === 0) return

    this.doneTarget.hidden = true
    this.playTarget.hidden = false
    this.render()
    this.focusInput()
  }

  render() {
    const card = this.deck[this.position]
    this.firstAttempt = true
    clearTimeout(this.wrongTimer)
    if (this.hasCardTarget) this.cardTarget.classList.remove("is-correct", "is-skipped", "is-wrong")
    this.promptTarget.textContent = card.front
    if (this.hasSrcBadgeTarget) this.srcBadgeTarget.textContent = (card.src || "").toUpperCase()
    if (this.hasTgtBadgeTarget) this.tgtBadgeTarget.textContent = (card.tgt || "").toUpperCase()
    this.inputTarget.value = ""
    this.inputTarget.disabled = false
    this.inputTarget.classList.remove("is-valid", "is-invalid")
    this.feedbackTarget.textContent = ""
    this.feedbackTarget.className = "form-text mt-2"
    this.updateProgress()
  }

  updateProgress() {
    this.progressTarget.textContent = `${this.position} / ${this.deck.length}`
    this.scoreTarget.textContent = this.correct
  }

  onKey(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.check()
    }
  }

  check() {
    const card = this.deck[this.position]
    if (!card || this.inputTarget.disabled) return

    if (this.matches(this.inputTarget.value, card.back)) {
      if (this.firstAttempt) this.correct += 1
      this.inputTarget.classList.remove("is-invalid")
      this.inputTarget.classList.add("is-valid")
      this.feedbackTarget.textContent = this.correctTextValue
      this.feedbackTarget.className = "form-text mt-2 text-success fw-semibold"
      if (this.hasCardTarget) this.cardTarget.classList.add("is-correct")
      this.advanceSoon()
    } else {
      this.firstAttempt = false
      this.inputTarget.classList.add("is-invalid")
      this.feedbackTarget.className = "form-text mt-2 text-danger"
      this.flashWrong()
    }
  }

  flashWrong() {
    if (!this.hasCardTarget) return
    this.cardTarget.classList.add("is-wrong")
    clearTimeout(this.wrongTimer)
    this.wrongTimer = setTimeout(() => this.cardTarget.classList.remove("is-wrong"), 2000)
  }

  advanceSoon() {
    this.inputTarget.disabled = true
    setTimeout(() => this.next(), 550)
  }

  skip() {
    if (this.inputTarget.disabled) return
    this.firstAttempt = false
    if (this.hasCardTarget) this.cardTarget.classList.add("is-skipped")
    this.advanceSoon()
  }

  next() {
    this.position += 1
    if (this.position >= this.deck.length) {
      this.finish()
    } else {
      this.render()
      this.focusInput()
    }
  }

  reveal() {
    const card = this.deck[this.position]
    if (!card) return
    this.firstAttempt = false
    this.feedbackTarget.textContent = `${this.answerPrefixValue} ${card.back}`
    this.feedbackTarget.className = "form-text mt-2 text-secondary"
  }

  finish() {
    this.playTarget.hidden = true
    this.doneTarget.hidden = false
    if (this.hasDoneCountTarget) this.doneCountTarget.textContent = this.deck.length
    if (this.hasDoneScoreTarget) this.doneScoreTarget.textContent = this.correct
  }

  restart() {
    this.start()
  }

  focusInput() {
    requestAnimationFrame(() => this.inputTarget.focus())
  }

  matches(input, answer) {
    const got = this.normalize(input)
    return got !== "" &&
           (got === this.normalize(answer) || got === this.normalize(this.stripParens(answer)))
  }

  stripParens(text) {
    return text.replace(/\(.*?\)/g, "")
  }

  normalize(text) {
    return (text || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .replace(/ł/g, "l")
      .trim()
      .replace(/\s+/g, " ")
      .replace(/[.,!?;:¡¿"'’]+$/g, "")
  }

  shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[array[i], array[j]] = [array[j], array[i]]
    }
    return array
  }
}
