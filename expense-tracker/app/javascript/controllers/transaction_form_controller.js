import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaction-form"
export default class extends Controller {
  static targets = ["amount", "amountDisplay", "typeSelector"]

  connect() {
    this.formatAmount()
  }

  // Format amount input with currency formatting
  formatAmount() {
    if (this.hasAmountTarget) {
      const value = parseFloat(this.amountTarget.value)
      if (!isNaN(value)) {
        this.amountTarget.value = value.toFixed(2)
      }
    }
  }

  // Update amount display as user types
  updateAmountDisplay() {
    if (this.hasAmountDisplayTarget && this.hasAmountTarget) {
      const value = parseFloat(this.amountTarget.value)
      if (!isNaN(value)) {
        this.amountDisplayTarget.textContent = this.formatCurrency(value)
      } else {
        this.amountDisplayTarget.textContent = "$0.00"
      }
    }
  }

  // Update form styling based on transaction type
  updateTypeStyle(event) {
    const selectedType = event.target.value
    const form = this.element

    // Remove existing type classes
    form.classList.remove('border-green-500', 'border-red-500', 'border-l-4')

    // Add appropriate styling
    if (selectedType === 'income') {
      form.classList.add('border-l-4', 'border-green-500')
    } else if (selectedType === 'expense') {
      form.classList.add('border-l-4', 'border-red-500')
    }
  }

  // Helper to format currency
  formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount)
  }

  // Validate amount before submission
  validateAmount(event) {
    if (this.hasAmountTarget) {
      const value = parseFloat(this.amountTarget.value)
      if (isNaN(value) || value <= 0) {
        event.preventDefault()
        alert('Please enter a valid amount greater than zero.')
        this.amountTarget.focus()
        return false
      }
    }
    return true
  }

  // Set today's date as default
  setToday(event) {
    event.preventDefault()
    const dateInput = this.element.querySelector('input[type="date"]')
    if (dateInput) {
      dateInput.value = new Date().toISOString().split('T')[0]
    }
  }
}
