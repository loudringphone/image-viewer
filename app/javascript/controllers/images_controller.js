import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="images"
export default class extends Controller {
  static targets = ["tbody"];

  connect() {
    const tbodyElement = this.tbodyTarget;
    consumer.subscriptions.create("ImageChannel", {
      received: (data) => {
        this.fetchImageData()
      }
    });
  }

  async fetchImageData() {
    const tbodyElement = this.tbodyTarget;
    return fetch("/images_json")
      .then(response => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then(data => {
        let html = '<tbody>'
        html = html + data.map(image => `
          <tr>
            <td><img src="${image.attachment.url}" alt="${image.title}"></td>
            <td>${image.title}</td>
            <td>${new Date(image.uploaded_time).toISOString().slice(0, 19).replace('T', ' ')}</td>
            <td>
              <div class='flex'>
                <a href="/images/${image.id}">View</a>
                <form action="/images/${image.id}" method="post" class="delete-form">
                  <input type="hidden" name="_method" value="delete">
                  <button type="submit" onclick="return confirm('Are you sure you want to delete this image?')">Delete</button>
                </form>
              </div>
            </td>
          </tr>
        `).join('');
        html = html + '</tbody>'
        return tbodyElement.innerHTML = html;
      })
      .catch(error => {
        console.error("Error fetching JSON data:", error);
        return null; // Return null or handle the error as needed
      });
  }
}
