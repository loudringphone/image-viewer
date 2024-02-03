import consumer from "channels/consumer"

consumer.subscriptions.create("ImageChannel", {
  connected() {
    console.log("Connected to ImageChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
  },

  send(message) {
    this.perform('received', { message: message });
  }
});
