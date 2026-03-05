# Fetches commit history from the GitHub REST API for the public changelog page.
# Results are cached per page to avoid hitting rate limits (~60 req/hr unauthenticated,
# ~5000 req/hr with GITHUB_USERNAME/GITHUB_PASSWORD env vars).
class GithubChangelogService
  REPO = "doshea/xword"
  PER_PAGE = 20
  CACHE_TTL = 1.hour
  TIMEOUT = 10

  # Returns { commits: [...], page:, per_page:, total_pages: } or nil on failure.
  # Each commit: { sha:, message:, date:, url:, category: }
  def self.fetch(page: 1)
    Rails.cache.fetch("changelog_page_#{page}", expires_in: CACHE_TTL) do
      fetch_from_github(page)
    end
  rescue StandardError => e
    Rails.logger.error("GithubChangelogService: #{e.class} — #{e.message}")
    nil
  end

  class << self
    private

    def fetch_from_github(page)
      url = "https://api.github.com/repos/#{REPO}/commits"
      options = {
        query: { page: page, per_page: PER_PAGE },
        headers: { "User-Agent" => "CrosswordCafe", "Accept" => "application/vnd.github.v3+json" },
        timeout: TIMEOUT
      }

      if ENV["GITHUB_USERNAME"].present? && ENV["GITHUB_PASSWORD"].present?
        options[:basic_auth] = { username: ENV["GITHUB_USERNAME"], password: ENV["GITHUB_PASSWORD"] }
      end

      response = HTTParty.get(url, options)
      return nil unless response.success?

      commits = response.parsed_response.map do |c|
        {
          sha: c["sha"][0..6],
          message: c["commit"]["message"].lines.first.strip,
          date: Time.parse(c["commit"]["author"]["date"]).to_date,
          url: c["html_url"],
          category: categorize(c["commit"]["message"])
        }
      end

      total_pages = parse_last_page(response.headers["link"]) || page

      { commits: commits, page: page, per_page: PER_PAGE, total_pages: total_pages }
    end

    def categorize(message)
      case message
      when /\AFix/i           then :fix
      when /\AAdd/i           then :feature
      when /\ARebuild|Modernize|Refactor|Extract/i then :improve
      when /\APolish|Pixel|Visual|Clean/i          then :polish
      else :update
      end
    end

    # GitHub Link header: <url?page=37>; rel="last"
    def parse_last_page(link_header)
      return nil unless link_header
      match = link_header.match(/page=(\d+)>;\s*rel="last"/)
      match ? match[1].to_i : nil
    end
  end
end
