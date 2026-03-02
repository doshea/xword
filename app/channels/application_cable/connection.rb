module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = cookies.signed[:auth_token]
      User.find_by_auth_token(token) if token
    end
  end
end