import { Controller } from 'stimulus';
import flatpickr from 'plugins/flatpickr/flatpickr';

export default class extends Controller {
  static targets = [
    'dateSelection'
  ]

  connect() {
    flatpickr(this.dateSelectionTarget, {
      // locale: "fr", # replace by flatpickr.localize(French)
      // mode: "range",
      minDate: 'today',
      altInput: true,
      altFormat: "D j F Y",
      dateFormat: "Y-m-d"
    });
  }
}
