# README

## Introduction
Welcome to the this `Rails` image viewer application! This README provides a comprehensive overview of the project, including setup instructions, implementation details, and usage guidelines.

#### How to run
- `git clone git@github.com:loudringphone/medical-image-viewer.git`
- `cd medical-image-viewer`
- `rails db:migrate`
- `bundle install`
- `rake assets:precompile`

##### Installing Redis
###### On Linux
- `wget http://download.redis.io/redis-stable.tar.gz`
- `tar xvzf redis-stable.tar.gz`
- `cd redis-stable`
- `make`
- `make install`
###### On Mac
- `brew install redis`
##### Starting the servers
- `./bin/setup`
- `./bin/rails s`
- `redis-server`

## User View Tracking with Action Cable
In this project, I've explored the integration of Stimulus with Action Cable, which proved to be an engaging exercise. Utilizing Action Cable to track user views was initially more challenging than expected.

Initially, I attempted to implement user tracking by creating a User model and assigning cookies to users. This approach involved storing attributes like image_last_viewed and image_last_seen. While straightforward, I found it to be somewhat inefficient. I created a scope in the image model to retrieve users viewing a particular image within a set timeframe, say, 5 seconds. However, I later realized this approach was not optimal.

```
app/models/visitor.rb (now deprecated)
scope :viewed_image_within_5_sec, ->(image_id) {
  where("last_seen_at > ? AND image_last_viewed = ?", 5.seconds.ago, image_id)
}
```

Upon further exploration, I discovered Action Cable, a gem that facilitates the creation of channels for broadcasting data to users subscribed to those channels. Initially, I faced challenges configuring Action Cable with Redis, but with perseverance, I managed to configure both server-side and client-side channels effectively. I implemented functionality such that when a user lands on an image, their count increases by 1, and when they navigate away or close the browser, their count decreases by 1. With thorough testing and debugging, I successfully implemented this feature, which I consider a significant improvement over my initial attempt.

```
app/channels/visitor_channel.rb
def subscribed
  stream_from "visitor_channel_#{params[:id]}"
  update_user_count(1)
end

def unsubscribed
  stop_stream_from "visitor_channel_#{params[:id]}"
  update_user_count(-1)
end
```

Lastly, to enhance the accuracy of view tracking, I've introduced an alternative method centered on recording unique cookies within a set. Leveraging the uniqueness of cookies offers a more precise gauge of user views compared to simplistic incrementation. While the previous method was susceptible to concurrency issues, this new strategy ensures accuracy by meticulously tracking individual user views. I've also implemented measures to secure access to the cookie count, restricting it to those with CSRF tokens for risk management purposes. Looking ahead, I recognize that cookie-based tracking may appear excessive for view counting alone. Thus, upon completing this assignment, I aim to explore more streamlined techniques, including the implementation of locking and concurrency mechanisms, to mitigate potential concurrency issues.

It is also important to note that while the second method would count each separate tab as a distinct view, this third approach considers each separate browser instance, as tabs within the same browser share the same cookie, as a unique view.

```
app/channels/application_cable/connection.rb (on branch cookie_count)
def current_user_cookie
  cookies['user_id']
end
```

Overall, through experimentation and iteration, I've achieved a robust solution for tracking user views, leveraging the combined power of `Stimulus`, `Action Cable` and `Redis`.

## Gem used

#### `ActionCable`, `Stimulus` and `Redis`
To track view counts, I've implemented a system where each user subscribing to an image channel increases the count by 1, leveraging `ActionCable` and `Redis`. When users leave, they're unsubscribed, decrementing the count. While `ActionCable` and `Redis` manage count records, the subscription and unsubscription processes are facilitated by `ActionCable` and `Stimulus`.


However, unexpected server shutdowns don't automatically unsubscribe users. To ensure accurate counts, I clear records when server is being initialised.


Besides dynamically displaying view counts, when an image is created or destroyed, the image list on the index page would automatically be updated without the need of refreshing the page. `ActionCable` would also broadcast a message that would be shown on the index page indicating which image has been created or destroyed. Additionally, if an user is on the image page when it's destroyed, they would also be redirected back to the index with an alert prompt indicating the deletion.

#### `CarrierWave`
To prevent image attachments from being pushed to Git, added the following to `.gitignore`: `public/uploads/tmp/*` and `public/uploads/image/attachment/*`. This ensures that files in these directories are not included in version control.

## Quality and Testing
To test the image models, I've utilised `shoulda-matchers` and `factory_bot` for efficient and readable tests. For verifying user interactions and HTML elements, `capybara` and `selenium-webdriver` were employed to ensure correctness in view pages. Although I encountered challenges in understanding how to test `action-cable`, I managed to do some basic testings. Given more time, I plan to delve deeper into testing with `action-cable` to enhance my skills and understanding further.

After running tests, I've observed that temporary images persist, so I've implemented code to automatically delete them post-testing.

```
config.after(:suite) do
  files_deleted = FileUtils.rm_rf(Dir[Rails.root.join('public/uploads/tmp/*')])
end
```

##  UI/UX
I've utilised `Hotwire` to elevate user experience with seamless page updates. When new images are created or removed, the index page refreshes automatically. Additionally, on the new image page, the save button remains disabled until the user completes the title field and attaches an image. `Tailwind CSS` provides basic styling, including a dynamic header indicating the current page and responsive design adapting to screen width.

## Git Usage
To maintain clarity in my Git workflow, I utilise feature branches, each dedicated to significant gem integrations or critical functionalities. While the goal is to focus solely on the designated branch, occasional work on unrelated branches may occur. This approach ensures focused development, with changes seamlessly integrated into the main branch upon completion.

## Conclusion
Thank you for considering this take-home assignment. Developing this application has been an enriching experience, allowing me to deepen my understanding of `Hotwire`, `Action Cable`, and real-time user interaction. I look forward to further refining and expanding this project in the future. If you have any questions or feedback, please don't hesitate to reach out.
