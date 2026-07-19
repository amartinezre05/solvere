import { Controller } from "@hotwired/stimulus"

// Previews the estimated installment while the user fills out the credit
// form, without saving anything. Fetches CreditsController#estimate with
// the current amount/rate/term/system values and swaps the result in.
export default class extends Controller {
  static targets = ["amount", "rate", "term", "system", "output"]
  static values = { url: String }

  update() {
    const params = new URLSearchParams({
      principal_amount: this.amountTarget.value,
      interest_rate_ea: this.rateTarget.value,
      term_months: this.termTarget.value,
      amortization_system: this.systemTarget.value
    })

    fetch(`${this.urlValue}?${params}`, { headers: { Accept: "text/html" } })
      .then(response => response.text())
      .then(html => { this.outputTarget.innerHTML = html })
  }
}
