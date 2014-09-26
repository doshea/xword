def time_difference_hash(most_recent, least_recent)
  seconds = most_recent - least_recent
  days = (seconds / (60*60*24)).floor
  seconds -= days*60*60*24
  hours = (seconds / (60*60)).floor
  seconds -= hours*60*60
  minutes = (seconds / 60).floor
  seconds -= minutes*60
  milliseconds = 1000*(seconds.round(3) - seconds.floor)
  seconds = seconds.floor
  {days: days, hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds}
end

def missing_this_year
  foty = Date.new(Date.today.year, 1, 1)

  nyt = User.find_by(username: 'nytimes')
  missing = []

  nyt_dates = nyt.crosswords.map{|cw| cw.published_at.to_date}

  (foty..Date.today).each do |date|
    unless date.in?(nyt_dates)
      missing << date
    end
  end
  missing
end

#used to add zeroes to the front of numbers
class Integer < Numeric
  def left_digits(digits)
    sprintf("%0#{digits}d", self)
  end
end