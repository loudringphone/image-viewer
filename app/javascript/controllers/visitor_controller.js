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
          if (data.user_count) {
            return countElement.textContent = data.user_count
          }
          if (data.code == 'destroy') {
            alert('This image has been deleted. You will now be redirected to the home page.')
            return window.location.href = '/';
          }
          if (data.code == 'next') {
            const next = document.querySelector('#next')
            if (next) {
              next.remove()
            }
            if (data.img_id) {
              console.log(data.img_id)
              const anchor = document.createElement('a');
            anchor.id = 'next';
            anchor.classList.add('cursor-pointer', 'ml-auto');
            anchor.href = `/images/${data.img_id}`;
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
            svg.setAttribute('viewBox', '0 0 24 24');
            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('d', 'm21.707 11.293-7-7A1 1 0 0 0 13 5v3H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h10v3a1 1 0 0 0 1.707.707l7-7a1 1 0 0 0 0-1.414z');
            path.style.fill = '#ccc';
            svg.appendChild(path);
            anchor.appendChild(svg);
            const span = document.createElement('span');
            span.textContent = 'Next';
            anchor.appendChild(span);
            navElement.appendChild(anchor);
            }
          }
          if (data.code == 'previous') {
            const previous = document.querySelector('#previous')
            if (previous) {
              previous.remove()
            }
            if (data.img_id) {
              console.log(data.img_id)
              const anchor = document.createElement('a');
              anchor.id = 'previous';
              anchor.classList.add('cursor-pointer', 'mr-auto');
              anchor.href = `/images/${data.img_id}`;
              const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
              svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
              svg.setAttribute('viewBox', '0 0 24 24');
              const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
              path.setAttribute('d', 'M21 8H11V5a1 1 0 0 0-1.707-.707l-7 7a1 1 0 0 0 0 1.414l7 7A1 1 0 0 0 11 19v-3h10a1 1 0 0 0 1-1V9a1 1 0 0 0-1-1z');
              path.style.fill = '#ccc';
              svg.appendChild(path);
              anchor.appendChild(svg);
              const span = document.createElement('span');
              span.textContent = 'Prev';
              anchor.appendChild(span);
              navElement.appendChild(anchor);
            }
          }
        },
      }
    );
  }
}