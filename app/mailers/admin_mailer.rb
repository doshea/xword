class AdminMailer < ActionMailer::Base
  full_sender = "Crossword Caf\u00e9 <info@crossword-cafe.com>"
  default from: full_sender

  def nyt_upload_error_email
    mail(to: full_sender, subject: "NYT Upload ERROR: #{Date.today.strftime('%A, %b %d %Y')}")
  end
end
