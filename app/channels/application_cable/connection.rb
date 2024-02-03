require 'base64'

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_cookie

    def connect
      self.current_user_cookie = current_user_cookie
    end

    def current_user_cookie
      cookies['user_id']
    end
  end
end
