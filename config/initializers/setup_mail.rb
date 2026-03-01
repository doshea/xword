ActionMailer::Base.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'crossword-cafe.org',
  user_name:            'dylan@crossword-cafe.org',
  password:             ENV['XWORD_EMAIL_PWD'],
  authentication:       'plain',
  enable_starttls_auto: true
}