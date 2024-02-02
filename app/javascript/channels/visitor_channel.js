import consumer from "channels/consumer"

consumer.subscriptions.create("VisitorChannel", {
  connected() {
    console.log("Connected to VisitorChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
});
