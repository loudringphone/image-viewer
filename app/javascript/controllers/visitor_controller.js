import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["msg"];
 
  connect() {
    const msgElement = this.msgTarget;
    setTimeout(() => {
      msgElement.style.visibility = 'visible'
    }, 275);
    const imageId = this.element.dataset.imageId;
    const visitor_id = this.element.dataset.visitorId;
    this.fetchVisitorCount()

    window.addEventListener('turbo:before-cache', function(event) {
      console.log(this)
      subscription.perform('unsubscribed', {});
    })


    const subscription = consumer.subscriptions.create(
      { channel: "VisitorChannel", id: imageId },
      {
        connected: () => {
          console.log(`Connected to VisitorChannel ${imageId}`);
          subscription.entered(visitor_id)
        },
        disconnected: () => {
        },
        received: (data) => {
          if (data.msg === `Someone has entered visitor channel ${imageId}`) {
            subscription.entered(data.visitor_id)
          }
          else if (data.msg === `Image ${imageId} has been destroyed.`) {
            alert('This image has been deleted. You will now be redirected to the home page.')
            window.location.href = '/';
          }
          subscription.fetchVisitorCount()
        },

        entered(visitor_id) {
          this.perform('entered', { data: visitor_id });
        },

        left(visitor_id) {
          this.perform('left', { data: visitor_id });
        },

        async fetchVisitorCount () {
          fetch(`/images/${imageId}/visitor_count`)
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
  async fetchVisitorCount () {
    const msgElement = this.msgTarget;
    const imageId = this.element.dataset.imageId;
    return fetch(`/images/${imageId}/visitor_count`)
    .then(response => response.json())
    .then(data => {
      let userCount = data.length;
      const message = `${userCount} ${userCount !== 1 ? 'users are' : 'user is'} currently viewing this image.`;
      msgElement.textContent = message
      return data
    })
    .catch(error => {
      console.error("Error fetching user count:", error);
    });
  }
}