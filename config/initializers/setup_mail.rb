ActionMailer::Base.smtp_settings ={
  :address              => "smtpout.secureserver.net",
  :port                 => 80,
  :domain               => 'crossword-cafe.com',
  :user_name            => 'info@crossword-cafe.com',
  :password             => ENV['XWORD_EMAIL_PWD'],
  :authentication       => 'plain',
  :enable_starttls_auto => true
}