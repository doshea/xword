# Fetches commit history from the GitHub REST API for the public changelog page.
# Results are cached per page to avoid hitting rate limits (~60 req/hr unauthenticated,
# ~5000 req/hr with GITHUB_USERNAME/GITHUB_PASSWORD env vars).
class GithubChangelogService
  REPO = "doshea/xword"
  PER_PAGE = 20
  CACHE_TTL = 1.hour
  TIMEOUT = 10

  # Commits matching these patterns are internal housekeeping, not user-facing changes.
  SKIP_PATTERNS = [
    /persona memory/i,
    /planner memory/i,
    /builder memory/i,
    /deployer memory/i,
    /shared\.md/i,
    /CLAUDE\.md/i,
    /memory files/i,
    /\AUpdate memory/i,
    /\AMerge branch/i,
    /\AMerge pull request/i,
    /review plans/i
  ].freeze

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

  # Visible for testing.
  def self.skip_commit?(message)
    SKIP_PATTERNS.any? { |pattern| message.match?(pattern) }
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

      commits = response.parsed_response.filter_map do |c|
        raw_message = c["commit"]["message"].lines.first.strip
        next if skip_commit?(raw_message)

        category = categorize(raw_message)
        {
          sha: c["sha"][0..6],
          message: strip_category_prefix(raw_message, category),
          date: Time.parse(c["commit"]["author"]["date"]).to_date,
          url: c["html_url"],
          category: category
        }
      end

      total_pages = parse_last_page(response.headers["link"]) || page

      { commits: commits, page: page, per_page: PER_PAGE, total_pages: total_pages }
    end

    def categorize(message)
      # Test/spec commits are housekeeping, not features — catch before "Add" pattern.
      return :update if message.match?(/\b(?:spec|test|rspec)\b/i) && !message.match?(/\bfix\b/i)

      case message
      when /\AFix/i           then :fix
      when /\AAdd/i           then :feature
      when /\ARebuild|Modernize|Refactor|Extract/i then :improve
      when /\APolish|Pixel|Visual|Clean/i          then :polish
      else :update
      end
    end

    # Removes the leading keyword that the badge already shows, so entries don't stutter
    # ("Fix Fix edit page..." → "Edit page..."). The :update category is the else-fallback
    # whose verbs ("Show", "Move", "Reduce") ARE the useful description — don't strip those.
    def strip_category_prefix(message, category)
      keyword_map = {
        fix:     /\AFix\b\s*/i,
        feature: /\AAdd\b\s*/i,
        improve: /\A(?:Rebuild|Modernize|Refactor|Extract)\b\s*/i,
        polish:  /\A(?:Polish|Pixel-perfect\s+polish:?\s*|Visual|Clean)\b\s*/i
      }
      pattern = keyword_map[category]
      return message unless pattern

      cleaned = message.sub(pattern, "")
      # Capitalize first letter after stripping
      cleaned.sub(/\A\w/) { |c| c.upcase }
    end

    # GitHub Link header: <url?page=37>; rel="last"
    def parse_last_page(link_header)
      return nil unless link_header
      match = link_header.match(/page=(\d+)>;\s*rel="last"/)
      match ? match[1].to_i : nil
    end
  end
end
