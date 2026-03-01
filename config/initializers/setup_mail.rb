ActionMailer::Base.smtp_settings ={
  :address              => "smtpout.secureserver.net",
  :port                 => 587,
  :domain               => 'crossword-cafe.com',
  :user_name            => 'info@crossword-cafe.com',
  :password             => ENV['XWORD_EMAIL_PWD'],
  :authentication       => 'plain',
  :enable_starttls_auto => true
}