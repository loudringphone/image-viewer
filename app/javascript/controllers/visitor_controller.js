import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["msg"];

  handleBeforeCache = () => {
    if (this.subscription) {
      this.subscription.disconnected();
    }
  };

  connect() {
    const msgElement = this.msgTarget;
    setTimeout(() => {
      msgElement.style.visibility = 'visible'
    }, 275);
    const imageId = this.element.dataset.imageId;
    // this.fetchVisitorCount()
    window.addEventListener('turbo:before-cache', this.handleBeforeCache)

    this.subscription = consumer.subscriptions.create(
      { channel: "VisitorChannel", id: imageId },
      {
        connected: () => {
          console.log(`Connected to VisitorChannel ${imageId}`);
        },
        disconnected: () => {
          console.log(`Bye VisitorChannel ${imageId}`);
          consumer.subscriptions.remove(this.subscription)
          window.removeEventListener('turbo:before-cache', this.handleBeforeCache)
        },
        received: (data) => {
          console.log(data.msg)
          if (data.msg === `Image ${imageId} has been destroyed.`) {
            alert('This image has been deleted. You will now be redirected to the home page.')
            window.location.href = '/';
          }
          this.fetchVisitorCount()
        },
      }
    );
  }
  async fetchVisitorCount () {
    const msgElement = this.msgTarget;
    const imageId = this.element.dataset.imageId;
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    return fetch(`/images/${imageId}/user_count`, {
      method: "GET",
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        "X-CSRF-Token": csrfToken
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      countElement.textContent = data
      return data
    })
    .catch(error => {
      console.error("Error fetching user count:", error);
    });
  }
}