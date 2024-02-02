import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

// Connects to data-controller="images"
export default class extends Controller {
  connect() {
    // const msgElement = this.msgTarget;
    // consumer.subscriptions.create("ImageChannel", {
    //   received: (data) => {
    //     const visitorCount = data.visitor_count;
    //     const message = `${visitorCount} ${visitorCount !== 1 ? 'visitors' : 'visitor'} currently viewing this image.`;
    //     msgElement.textContent = message;
    //     setTimeout(() => {
    //       this.fetchVisitorCount();
    //     }, 5000);
    //   }
    // });
  }
}
