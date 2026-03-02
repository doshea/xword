module AuthHelpers
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_in_admin
    session[:user_id] = create(:admin).id
  end
end

module RequestAuthHelpers
  TEST_PASSWORD = 'password123'

  def log_in_as(user)
    post '/login', params: { username: user.username, password: TEST_PASSWORD }
  end
end
