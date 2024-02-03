import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["msg"];

  connect() {
    const msgElement = this.msgTarget;
    setTimeout(() => {
      msgElement.style.visibility = 'visible'
    }, 275);
    const imageId = this.element.dataset.imageId;
    const visitor_id = this.element.dataset.visitorId;
    this.fetchImageData()
    this.subscription = consumer.subscriptions.create(
      { channel: "VisitorChannel", id: imageId },
      {
        connected: () => {
          console.log(`Connected to VisitorChannel ${imageId}`);
          this.subscription.entered(visitor_id)
          this.subscription.fetchImageData()
        },
        disconnected: () => {
          this.subscription.left(data.visitor_id)
          this.subscription.fetchImageData()
        },
        received: (data) => {
          console.log(data.msg)
          if (data.msg === `Someone has entered visitor channel ${imageId}`) {
            this.subscription.entered(data.visitor_id)
          }
          else if (data.msg === `Someone has left visitor channel ${imageId}`) {
            this.subscription.left(data.visitor_id)
          }
          this.subscription.fetchImageData()
        },

        entered(visitor_id) {
          this.perform('entered', { data: visitor_id });
          this.fetchImageData()
        },

        left(visitor_id) {
          this.perform('left', { data: visitor_id });
          this.fetchImageData()
        },

        async fetchImageData () {
          return fetch(`/images/${imageId}/visitor_count`)
          .then(response => response.json())
          .then(data => {
            let userCount = data.length;
            const message = `${userCount} ${userCount !== 1 ? 'users are' : 'user is'} currently viewing this image.`;
            return msgElement.textContent = message
          })
          .catch(error => {
            console.error("Error fetching user count:", error);
          });
        }
      }
    );
  }
  async fetchImageData () {
    const msgElement = this.msgTarget;
    const imageId = this.element.dataset.imageId;
    return fetch(`/images/${imageId}/visitor_count`)
    .then(response => response.json())
    .then(data => {
      let userCount = data.length;
      const message = `${userCount} ${userCount !== 1 ? 'users are' : 'user is'} currently viewing this image.`;
      return msgElement.textContent = message
    })
    .catch(error => {
      console.error("Error fetching user count:", error);
    });
  }
}