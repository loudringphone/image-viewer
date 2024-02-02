import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["msg"];
  connect() {
    this.fetchImageData()
    const msgElement = this.msgTarget;
    setTimeout(() => {
      msgElement.style.visibility = 'visible'
    }, 100);
    const imageId = this.element.dataset.imageId;
    consumer.subscriptions.create({ channel: "VisitorChannel", id: imageId }, {
      received: (data) => {
        this.fetchImageData()
      },

      connected() {
        this.fetchImageData()
      },

      disconnected() {
        this.fetchImageData()
      }
    });
  }
  async fetchImageData() {
    const imageId = this.element.dataset.imageId;
    const msgElement = this.msgTarget;
    return fetch(`/images/${imageId}/visitor_count`)
    .then(response => response.json())
    .then(data => {
      const userCount = data.user_count;
      console.log(`User count for image ${imageId}: ${userCount}`);
      userCount == 0 ? userCount = 1 : userCount
      const message = `${userCount} ${userCount !== 1 ? 'users are' : 'user is'} currently viewing this image.`;
      return msgElement.textContent = message
    })
    .catch(error => {
      console.error("Error fetching user count:", error);
    });
  }
}
