class UserMailer < ActionMailer::Base
  layout 'default_mail'

  full_sender = "Crossword Caf\u00e9 <dylan@crossword-cafe.org>"
  default from: full_sender

  def reset_password_email(user)
    @user = user
    mail(to: @user.named_email_address, subject: "Reset your Crossword Caf\u00e9 password")
  end
end
