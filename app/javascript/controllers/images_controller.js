import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

// Connects to data-controller="images"
export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create("ImageChannel", {
      received: (data) => {
        this.element.textContent = `${data.visitor_count} visitor${data.visitor_count !== 1 ? 's' : ''} currently viewing this image.`
      }
    })
  }
}
