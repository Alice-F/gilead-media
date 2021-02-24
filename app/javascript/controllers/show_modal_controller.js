import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'modalId'
  ]

  connect() {
    $('#' + this.modalIdTarget.id).modal('show');
  }
}
