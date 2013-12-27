class UserMailer < ActionMailer::Base
  layout 'default_mail'

  full_sender = "Crossword Caf\u00e9 <info@crossword-cafe.com>"
  default from: full_sender

  def test_email(user)
    @user = user
    @url  = "http://www.crossword-cafe.com"
    mail(to: @user.named_email_address, subject: "Welcome to Crossword Caf\u00e9")
  end

  def reset_password_email(user)
    @user = user
    mail(to: @user.named_email_address, subject: "Reset your Crossword Caf\u00e9 password")
  end
end
