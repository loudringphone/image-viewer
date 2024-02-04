import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["nav", "count"];

  handleBeforeCache = () => {
    if (this.subscription) {
      this.subscription.disconnected();
    }
  };

  connect() {
    const navElement = this.navTarget;
    const countElement = this.countTarget;
    setTimeout(() => {
      countElement.style.visibility = 'visible'
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
            return window.location.href = '/';
          }
          const nextImgMsg = /Next image (\d+) has been created/;
          const nextImg = nextImgMsg.exec(data.msg);
          console.log(nextImg)
          if (nextImg) {
            const anchor = document.createElement('a');
            anchor.id = 'next';
            anchor.classList.add('cursor-pointer', 'ml-auto');
            anchor.href = `/images/${nextImg[1]}`;
            anchor.textContent = 'Next';
            navElement.appendChild(anchor);
          }
          this.fetchVisitorCount()
        },
      }
    );
  }
  async fetchVisitorCount () {
    const countElement = this.countTarget;
    const imageId = this.element.dataset.imageId;
    return fetch(`/images/${imageId}/user_count`)
    .then(response => response.json())
    .then(data => {
      countElement.textContent = data.user_count
      return data
    })
    .catch(error => {
      console.error("Error fetching user count:", error);
    });
  }
}