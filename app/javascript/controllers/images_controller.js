import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="images"
export default class extends Controller {
  static targets = ["container", "tbody"];

  connect() {
    const containerElement = this.containerTarget;
    consumer.subscriptions.create("ImageChannel", {
      received: (data) => {
        this.fetchImages()
        const notice = document.querySelector('#notice')
        if (notice) {
          notice.remove()
        }
        const childElement = document.createElement('div');
        childElement.classList.add('text-sm', 'text-red-400');
        childElement.id = 'notice'
        childElement.innerHTML = `${data.msg.slice(0, -1)} by another user.`;
        const firstChild = containerElement.firstChild;
        containerElement.insertBefore(childElement, firstChild);
      }
    });
  }

  async fetchImages() {
    const tbodyElement = this.tbodyTarget;
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    return fetch("/images_json", {
      method: "GET",
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        "X-CSRF-Token": csrfToken
      },
      credentials: 'same-origin'
    })
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
            <td><a href="/images/${image.id}"><img  class="h-[50px]" src="${image.attachment.url}" alt="${image.title}"></a></td>
            <td><a href="/images/${image.id}">${image.title}</a></td>
            <td>
              <span class='text-xs text-wrap'>${new Date(image.created_at)
              .toLocaleString('en', {
                day: '2-digit',
                month: 'short',
                year: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: false
              })}
              </span>
            </td>
            <td>
              <div class='flex'>
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
