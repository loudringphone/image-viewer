import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="visitor"
export default class extends Controller {
  static targets = ["msg"];

  connect() {
    this.fetchVisitorCount();
    this.startFetchingInterval();
  }

  fetchVisitorCount() {
    const imageId = this.element.dataset.imageId;
    fetch(`/images/${imageId}/visitor_count`)
      .then(response => response.json())
      .then(data => {
        this.msgTarget.textContent = data.visitor_count_msg;
      })
      .catch(error => {
        console.error("Error fetching visitor count:", error);
      });
  }
  startFetchingInterval() {
    this.fetchInterval = setInterval(() => {
      this.fetchVisitorCount();
    }, 5000);
  }
}
