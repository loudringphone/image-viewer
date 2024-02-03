# README

#### How to run
- `git clone git@github.com:loudringphone/medical-image-viewer.git`
- `cd medical-image-viewer/`
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
- `./bin/cable`
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


Lastly, to ensure accurate tracking of views, I devised an alternative method of counting views by recording unique cookies in a set. As cookies are unique to each user, counting them provides a more accurate depiction of user views. I integrated this approach with Action Cable's capabilities to further enhance the accuracy of view tracking on a seperate branch as a backup plan in case the previous method fails.

```
app/channels/application_cable/connection.rb (on branch cookie_count)
def current_user_cookie
  cookies['user_id']
end
```


Overall, through experimentation and iteration, I've achieved a robust solution for tracking user views, leveraging the combined power of Stimulus, Action Cable and Redis.
