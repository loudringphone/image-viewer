// import consumer from "channels/consumer"

// document.addEventListener("DOMContentLoaded", () => {
//   const divElement = document.querySelector("[data-controller='visitor']");
//   const imageId = divElement.getAttribute("data-image-id");
//   consumer.subscriptions.create({ channel: "VisitorChannel", id: imageId }, {
//     connected() {
//       console.log(`Connected to VisitorChannel ${imageId}`);
//     },

//     disconnected() {
//       // Called when the subscription has been terminated by the server
//     },

//     received(data) {
//       console.log("Received data:", data);
//       // Handle received data here
//     }
//   });
// });