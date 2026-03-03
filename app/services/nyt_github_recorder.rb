# Uploads NYT puzzle JSON to the GitHub mirror repo.
# Extracted from Newyorkable concern.
class NytGithubRecorder
  TIMEOUT = 10 # seconds

  # Parse the puzzle JSON to extract the date, then upload to GitHub.
  def self.smart_record(puzzle_json)
    pz = JSON.parse(puzzle_json)
    pz_title = pz['title'] || pz[:title]
    begin
      pz_date = Date.parse(pz_title)
    rescue ArgumentError
      alt_date = pz['date'] || pz[:date]
      pz_date = Date.strptime(alt_date, '%m/%d/%Y')
    end
    record_on_github(puzzle_json, pz_date)
  end

  # Fetch puzzle from xwordinfo for the given date, then upload to GitHub.
  def self.record_date_on_github(date)
    puzzle_json = NytPuzzleFetcher.from_xwordinfo(date)
    record_on_github(puzzle_json, date)
  end

  # Upload puzzle JSON to the GitHub repo via the Contents API.
  def self.record_on_github(puzzle_json, date)
    return nil if puzzle_json.nil?

    url_stem = 'https://api.github.com'
    repo = 'nyt_crosswords'
    username = 'doshea'

    year = date.year
    month = sprintf('%02d', date.month)
    day = sprintf('%02d', date.day)

    auth = { username: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'] }
    create_url = url_stem + "/repos/#{username}/#{repo}/contents/#{year}/#{month}/#{day}.json"

    HTTParty.put(
      create_url,
      basic_auth: auth,
      headers: { "User-Agent" => ENV['GITHUB_USERNAME'] },
      body: {
        message: "NYT puzzle for #{date.strftime('%a, %b %d, %Y')}",
        content: Base64.strict_encode64(puzzle_json)
      }.to_json,
      timeout: TIMEOUT
    )
  end
end
