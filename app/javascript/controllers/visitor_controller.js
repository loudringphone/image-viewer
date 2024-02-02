import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="visitor"
export default class extends Controller {
  static targets = ["msg"];
  connect() {
    const msgElement = this.msgTarget;
    consumer.subscriptions.create("VisitorChannel", {
      received: (data) => {
        const visitorCount = data.visitor_count;
        const message = `${visitorCount} ${visitorCount !== 1 ? 'visitors' : 'visitor'} currently viewing this image.`;
        msgElement.textContent = message;
        setTimeout(() => {
          this.fetchVisitorCount();
        }, 5000);
      }
    });
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
}
