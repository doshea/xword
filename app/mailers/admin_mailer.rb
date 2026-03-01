class AdminMailer < ActionMailer::Base
  SENDER = "Crossword Caf\u00e9 <dylan@crossword-cafe.org>".freeze
  default from: SENDER

  def nyt_upload_error_email
    mail(to: SENDER, subject: "NYT Upload ERROR: #{Date.today.strftime('%A, %b %d %Y')}")
  end
end
