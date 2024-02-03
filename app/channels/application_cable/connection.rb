module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = current_user
    end

    def current_user
      user_id = cookies.signed[:user_id] || SecureRandom.hex(16)
      cookies.permanent.signed[:user_id] = user_id
      Visitor.find_or_initialize_by(cookie: cookies.signed[:user_id])
    end
  end
end
