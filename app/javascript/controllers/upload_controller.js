import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["title", "attachment", "preview"];

  connect() {
    const titleElement = this.titleTarget;
    console.log(titleElement)
  }
  previewImage(){
    console.log(this.attachmentTarget.files)
    const preview = this.previewTarget
    const file = this.attachmentTarget.files[0];
    const reader = new FileReader();
    reader.onload = function(e) {
      preview.src = e.target.result;
    }
    reader.readAsDataURL(file);
  }
}
