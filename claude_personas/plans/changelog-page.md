# Changelog Page — Implementation Plan

## Overview

Public `/changelog` page that displays the git commit history as a timeline,
accessible from the footer alongside About/FAQ/Contact/Stats.

## Architecture Decision: GitHub API (not DB)

**Recommendation: Live-fetch from GitHub REST API + Rails cache.**

Why not a DB table:
- Commits are immutable — no need for persistence
- Would require migration, populate rake task, and deploy hook
- Over-engineered for read-only display of ~724 entries

Why GitHub API works:
- Repo is public (`doshea/xword`) — unauthenticated: 60 req/hr
- `GITHUB_USERNAME`/`GITHUB_PASSWORD` env vars already set → authenticated: 5,000 req/hr
- `HTTParty` already in Gemfile, same pattern as `NytGithubRecorder`
- GitHub paginates commits natively (`?page=N&per_page=20`)
- 1-hour cache per page → real API calls maybe ~3/day

Fallback: if API fails, show a friendly message + link to `github.com/doshea/xword/commits`.

## Files to Create/Modify

### New files (3)
1. `app/services/github_changelog_service.rb` — fetch + cache + parse
2. `app/views/pages/changelog.html.haml` — timeline view
3. `app/assets/stylesheets/changelog.scss` — BEM styles (`.xw-changelog`)

### Modified files (3)
4. `app/controllers/pages_controller.rb` — add `changelog` action
5. `config/routes.rb` — add `get '/changelog'`
6. `app/views/layouts/partials/_footer.html.haml` — add Changelog link

### Test file (1)
7. `spec/requests/pages_changelog_spec.rb` — request spec

## Detailed Design

### 1. `GitHubChangelogService`

```ruby
class GitHubChangelogService
  REPO = "doshea/xword"
  PER_PAGE = 20
  CACHE_TTL = 1.hour
  TIMEOUT = 10

  # Returns { commits: [...], page:, total_pages: }
  def self.fetch(page: 1)
    # Cache key per page
    Rails.cache.fetch("changelog_page_#{page}", expires_in: CACHE_TTL) do
      fetch_from_github(page)
    end
  rescue => e
    Rails.logger.error("Changelog fetch failed: #{e.message}")
    nil  # Controller renders fallback
  end

  private

  def self.fetch_from_github(page)
    url = "https://api.github.com/repos/#{REPO}/commits"
    options = {
      query: { page: page, per_page: PER_PAGE },
      headers: { "User-Agent" => "CrosswordCafe", "Accept" => "application/vnd.github.v3+json" },
      timeout: TIMEOUT
    }
    # Use auth if available (5000 req/hr vs 60)
    if ENV['GITHUB_USERNAME'].present? && ENV['GITHUB_PASSWORD'].present?
      options[:basic_auth] = { username: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD'] }
    end

    response = HTTParty.get(url, options)
    return nil unless response.success?

    commits = response.parsed_response.map do |c|
      {
        sha: c["sha"][0..6],
        message: c["commit"]["message"].lines.first.strip,
        date: Time.parse(c["commit"]["author"]["date"]),
        url: c["html_url"],
        category: categorize(c["commit"]["message"])
      }
    end

    # Parse Link header for total pages
    total_pages = parse_last_page(response.headers["link"]) || page

    { commits: commits, page: page, total_pages: total_pages }
  end

  def self.categorize(message)
    case message
    when /\AFix/i then :fix
    when /\AAdd/i then :feature
    when /\ARebuild|Modernize|Refactor/i then :improve
    when /\APolish|Pixel|Visual/i then :polish
    else :other
    end
  end

  def self.parse_last_page(link_header)
    # GitHub Link: <url?page=37>; rel="last"
    return nil unless link_header
    match = link_header.match(/page=(\d+)>;\s*rel="last"/)
    match ? match[1].to_i : nil
  end
end
```

### 2. Controller Action

```ruby
# GET /changelog
def changelog
  page = [params[:page].to_i, 1].max
  @result = GitHubChangelogService.fetch(page: page)
  if @result
    @commits = @result[:commits]
    @page = @result[:page]
    @total_pages = @result[:total_pages]
  end
end
```

### 3. View — Timeline grouped by date

Uses the `topper_stopper` layout like About/FAQ/Contact. Commits grouped by date.
Each entry shows:
- Category badge (colored dot or pill: Fix, Feature, Improve, Polish)
- Commit message (first line only)
- Short SHA linking to GitHub

Pagination: standard `xw-pagination` bar (prev/next + page numbers), manually
built since data isn't a WillPaginate collection. Could alternatively use
`WillPaginate::Collection.create` to wrap the array and reuse the helper.

**Recommendation:** Use `WillPaginate::Collection.create(page, per_page, total)`
so we get the exact same pagination UI as admin/profile pages for free.

### 4. Styles (`.xw-changelog`)

```
.xw-changelog                    — outer container
.xw-changelog__group             — date group
.xw-changelog__date              — date heading (e.g., "March 4, 2026")
.xw-changelog__entry             — single commit row
.xw-changelog__badge             — category badge (--fix, --feature, --improve, --polish)
.xw-changelog__message           — commit message text
.xw-changelog__sha               — short hash link to GitHub
.xw-changelog__fallback          — error/fallback message
```

Aesthetic: editorial "release notes" feel. Date headings in Playfair Display,
entries in Lora, SHAs in Courier Prime. Category badges as small colored pills.
Use `--color-accent` (green) for features, `--color-warning` for fixes,
`--color-info` for improvements, `--color-text-muted` for polish/other.

### 5. Route + Footer

```ruby
# routes.rb
get '/changelog' => 'pages#changelog'

# _footer.html.haml — add between Contact and Stats
= link_to 'Changelog', changelog_path
```

### 6. Tests

Request spec covering:
- Successful fetch → renders timeline with commits
- API failure → renders fallback with GitHub link
- Pagination param forwarded correctly
- Stub `HTTParty.get` (never hit real GitHub in tests)

## Filtering Decision (for user input)

Some commits are purely internal ("Update persona memory files", "Update CLAUDE.md").
Options:
1. **Show everything** — full transparency
2. **Filter out noise** — skip commits matching patterns like "memory files", "persona"
3. **Let the view handle it** — show all but group/collapse maintenance commits

**Recommendation:** Option 1 (show everything). The transparency is part of the charm,
especially given the About page's honesty about AI involvement. If it feels noisy after
seeing it live, we can add a filter list later.

## Risks

1. **Heroku has no `.git`** — this is exactly why we use the GitHub API, not `git log`
2. **Rate limiting** — 1-hour cache + authenticated requests = non-issue
3. **API down** — graceful fallback to "Visit our GitHub" message
4. **Co-authored commits** — `message.lines.first.strip` correctly grabs only the title line

## Acceptance Criteria

- [ ] `/changelog` renders a paginated timeline of commits
- [ ] Commits grouped by date, newest first
- [ ] Each entry shows category badge, message, date, SHA link
- [ ] Pagination works (prev/next/page numbers)
- [ ] Footer shows "Changelog" link
- [ ] Graceful fallback when GitHub API unavailable
- [ ] All colors/fonts/spacing use design tokens
- [ ] Request spec passes with stubbed GitHub API
