# Read-only fetch methods for NYT crossword puzzle JSON.
# Extracted from Newyorkable concern — used by ApiController for JSON passthrough.
class NytPuzzleFetcher
  TIMEOUT = 10 # seconds

  # Parse the date from a puzzle hash (string or symbol keys).
  # Tries Date.parse on the title first, falls back to strptime on the 'date' field.
  def self.parse_puzzle_date(pz)
    pz_title = pz['title'] || pz[:title]
    Date.parse(pz_title)
  rescue ArgumentError
    alt_date = pz['date'] || pz[:date]
    Date.strptime(alt_date, '%m/%d/%Y')
  end

  # Fetch puzzle JSON from the GitHub mirror repo.
  # Returns raw response body (JSON string by default).
  def self.from_github(date = Date.today, format = 'json')
    url = "https://raw.githubusercontent.com/doshea/nyt_crosswords/master/#{date.year}/#{'%02d' % date.month}/#{'%02d' % date.day}.json"
    response = HTTParty.get(url, format: format.nil? ? format : format.to_s, timeout: TIMEOUT)
    ensure_utf8(response)
  end

  # Fetch puzzle JSON from xwordinfo.com.
  # Returns raw response body (JSON string by default).
  def self.from_xwordinfo(date = Date.today, format = 'json')
    url = "http://www.xwordinfo.com/JSON/Data.aspx?date=#{date.month}/#{date.day}/#{date.year}"
    response = HTTParty.get(url, format: format.nil? ? format : format.to_s, timeout: TIMEOUT)
    ensure_utf8(response)
  end

  # Force UTF-8 encoding on ASCII-8BIT responses to prevent double-encoding
  # when strings are later passed through Loofah (strip_tags).
  def self.ensure_utf8(response)
    body = response.body
    if body.is_a?(String) && body.encoding == Encoding::ASCII_8BIT
      body.force_encoding('UTF-8')
    end
    response
  end
  private_class_method :ensure_utf8
end
