# Read-only fetch methods for NYT crossword puzzle JSON.
# Extracted from Newyorkable concern — used by ApiController for JSON passthrough.
class NytPuzzleFetcher
  TIMEOUT = 10 # seconds

  # Fetch puzzle JSON from the GitHub mirror repo.
  # Returns raw response body (JSON string by default).
  def self.from_github(date = Date.today, format = 'json')
    url = "https://raw.githubusercontent.com/doshea/nyt_crosswords/master/#{date.year}/#{'%02d' % date.month}/#{'%02d' % date.day}.json"
    HTTParty.get(url, format: format.nil? ? format : format.to_s, timeout: TIMEOUT)
  end

  # Fetch puzzle JSON from xwordinfo.com.
  # Returns raw response body (JSON string by default).
  def self.from_xwordinfo(date = Date.today, format = 'json')
    url = "http://www.xwordinfo.com/JSON/Data.aspx?date=#{date.month}/#{date.day}/#{date.year}"
    HTTParty.get(url, format: format.nil? ? format : format.to_s, timeout: TIMEOUT)
  end
end
