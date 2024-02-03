# README

### How to run
- `git clone git@github.com:loudringphone/medical-image-viewer.git`
- `cd medical-image-viewer/`
- `rails db:migrate`
- `bundle install`
- `rake assets:precompile`

#### Installing Redis
##### On Linux**
- `wget http://download.redis.io/redis-stable.tar.gz`
- `tar xvzf redis-stable.tar.gz`
- `cd redis-stable`
- `make`
- `make install`
##### On Mac
- `brew install redis`
#### Starting the servers
- `./bin/setup`
- `./bin/cable`
- `./bin/rails s`
- `redis-server`
