// ---------------------------------------------------------------------------
// FormValidationController — client-side inline validation
// ---------------------------------------------------------------------------
// Validates form fields on blur, clears errors on input, and prevents
// submission when any field is invalid. Uses the HTML5 Constraint Validation
// API (checkValidity / validity) and applies existing BEM error classes:
//   .xw-input--error / .xw-textarea--error  — red border on the input
//   .xw-field-error                         — error message below the input
//
// Usage:
//   = form_with ..., data: { controller: 'form-validation' } do |f|
//     .xw-field
//       = f.label :email, class: 'xw-label'
//       = f.email_field :email, required: true, class: 'xw-input'
// ---------------------------------------------------------------------------

class FormValidationController extends Stimulus.Controller {
  connect() {
    this.element.setAttribute('novalidate', '');
    this.element.addEventListener('blur', this.onBlur.bind(this), true);
    this.element.addEventListener('input', this.onInput.bind(this), true);
    this.element.addEventListener('submit', this.onSubmit.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('blur', this.onBlur.bind(this), true);
    this.element.removeEventListener('input', this.onInput.bind(this), true);
    this.element.removeEventListener('submit', this.onSubmit.bind(this));
  }

  // ---- Event handlers -----------------------------------------------------

  onBlur(event) {
    var field = event.target;
    if (!this.isValidatable(field)) return;
    this.validateField(field);
  }

  onInput(event) {
    var field = event.target;
    if (!this.isValidatable(field)) return;
    // Only clear if the field already has an error shown
    if (this.hasError(field) && field.checkValidity()) {
      this.clearError(field);
    }
  }

  onSubmit(event) {
    var fields = this.validatableFields();
    var firstInvalid = null;

    for (var i = 0; i < fields.length; i++) {
      if (!this.validateField(fields[i]) && !firstInvalid) {
        firstInvalid = fields[i];
      }
    }

    if (firstInvalid) {
      event.preventDefault();
      firstInvalid.focus();
    }
  }

  // ---- Validation logic ---------------------------------------------------

  validateField(field) {
    if (field.checkValidity()) {
      this.clearError(field);
      return true;
    }
    this.showError(field, this.errorMessage(field));
    return false;
  }

  errorMessage(field) {
    var v = field.validity;

    if (v.valueMissing)   return 'This field is required';
    if (v.typeMismatch && field.type === 'email') return 'Please enter a valid email address';
    if (v.typeMismatch && field.type === 'url')   return 'Please enter a valid URL';
    if (v.typeMismatch)   return 'Please enter a valid value';
    if (v.tooShort)       return 'Must be at least ' + field.minLength + ' characters';
    if (v.tooLong)        return 'Must be no more than ' + field.maxLength + ' characters';
    if (v.patternMismatch) return field.title || 'Please match the required format';

    return field.validationMessage || 'This field is invalid';
  }

  // ---- DOM manipulation ---------------------------------------------------

  showError(field, message) {
    var errorClass = field.tagName === 'TEXTAREA' ? 'xw-textarea--error' : 'xw-input--error';
    field.classList.add(errorClass);

    var wrapper = field.closest('.xw-field');
    if (!wrapper) return;

    // Remove existing error message if any
    var existing = wrapper.querySelector('.xw-field-error');
    if (existing) existing.remove();

    var span = document.createElement('span');
    span.className = 'xw-field-error';
    span.setAttribute('role', 'alert');
    span.textContent = message;
    wrapper.appendChild(span);
  }

  clearError(field) {
    field.classList.remove('xw-input--error', 'xw-textarea--error');

    var wrapper = field.closest('.xw-field');
    if (!wrapper) return;

    var errorSpan = wrapper.querySelector('.xw-field-error');
    if (errorSpan) errorSpan.remove();
  }

  hasError(field) {
    return field.classList.contains('xw-input--error') ||
           field.classList.contains('xw-textarea--error');
  }

  // ---- Helpers ------------------------------------------------------------

  isValidatable(field) {
    var tag = field.tagName;
    return (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') &&
           field.type !== 'hidden' &&
           field.type !== 'submit' &&
           field.type !== 'button' &&
           field.closest('.xw-field');
  }

  validatableFields() {
    return Array.from(this.element.querySelectorAll('input, textarea, select')).filter(
      this.isValidatable.bind(this)
    );
  }
}

window.StimulusApp.register('form-validation', FormValidationController);
