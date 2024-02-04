import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ['title', 'description', 'attachment', 'preview', 'submit'];

  connect() {
  }
  previewImage(){
    const preview = this.previewTarget
    const filesLength = this.attachmentTarget.files.length
    if (filesLength > 0) {
      const file = this.attachmentTarget.files[0];
      const reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
      }
      reader.readAsDataURL(file);
    } else {
      preview.src = '';
    }
    this.handleInput()
  }
  handleInput() {
    const title = this.titleTarget
    const description = this.descriptionTarget
    const filesLength = this.attachmentTarget.files.length
    if (title.value.trim() !== '' && description.value.trim() !== '' && filesLength > 0) {
      this.enableSubmit()
    } else {
      this.disableSubmit()
    }
  }
  disableSubmit() {
    this.submitTarget.disabled = true;
    this.submitTarget.style.opacity = '0.5'
    this.submitTarget.style.pointerEvents = 'default'

  }
  enableSubmit() {
    this.submitTarget.disabled = false;
    this.submitTarget.style.opacity = '1'
    this.submitTarget.style.pointerEvents = 'auto'
  }
}
