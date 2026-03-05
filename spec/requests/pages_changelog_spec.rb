RSpec.describe 'Changelog', type: :request do
  let(:github_commits) do
    [
      {
        "sha" => "d846825abcdef1234567890",
        "commit" => {
          "message" => "Add solve timer and next-puzzle suggestion on win\n\nCo-Authored-By: Someone",
          "author" => { "name" => "Dylan", "date" => "2026-03-04T22:17:22Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/d846825"
      },
      {
        "sha" => "a2d8ff1abcdef1234567890",
        "commit" => {
          "message" => "Fix edit page save button: ghost style",
          "author" => { "name" => "Dylan", "date" => "2026-03-04T21:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/a2d8ff1"
      },
      {
        "sha" => "132be74abcdef1234567890",
        "commit" => {
          "message" => "Rebuild stats page as 6-section community dashboard",
          "author" => { "name" => "Dylan", "date" => "2026-03-03T18:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/132be74"
      },
      {
        "sha" => "bbbb111abcdef1234567890",
        "commit" => {
          "message" => "Update builder/planner memory and add review plans",
          "author" => { "name" => "Dylan", "date" => "2026-03-03T17:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/bbbb111"
      },
      {
        "sha" => "cccc222abcdef1234567890",
        "commit" => {
          "message" => "Add request specs for login flow",
          "author" => { "name" => "Dylan", "date" => "2026-03-03T16:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/cccc222"
      }
    ]
  end

  let(:success_response) do
    instance_double(
      HTTParty::Response,
      success?: true,
      parsed_response: github_commits,
      headers: { "link" => '<https://api.github.com/repos/doshea/xword/commits?page=37>; rel="last"' }
    )
  end

  # -------------------------------------------------------------------------
  # GET /changelog — success case
  # -------------------------------------------------------------------------
  describe 'GET /changelog' do
    before do
      # Clear cache to ensure fresh fetch
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'renders the changelog page' do
      get '/changelog'
      expect(response).to have_http_status(:ok)
    end

    it 'displays commit messages with category prefix stripped' do
      get '/changelog'
      # "Add solve timer..." → prefix "Add" stripped, badge shows "Feature"
      expect(response.body).to include('Solve timer and next-puzzle suggestion on win')
      expect(response.body).not_to include('Add solve timer')
      # "Fix edit page..." → prefix "Fix" stripped, badge shows "Fix"
      expect(response.body).to include('Edit page save button')
      expect(response.body).not_to include('Fix edit page')
    end

    it 'shows only the first line of multi-line commit messages' do
      get '/changelog'
      expect(response.body).not_to include('Co-Authored-By')
    end

    it 'groups commits by date' do
      get '/changelog'
      expect(response.body).to include('March 4, 2026')
      expect(response.body).to include('March 3, 2026')
    end

    it 'shows category badges' do
      get '/changelog'
      expect(response.body).to include('xw-changelog__badge--feature')
      expect(response.body).to include('xw-changelog__badge--fix')
      expect(response.body).to include('xw-changelog__badge--improve')
    end

    it 'links SHAs to GitHub' do
      get '/changelog'
      expect(response.body).to include('https://github.com/doshea/xword/commit/d846825')
      expect(response.body).to include('d846825')
    end

    it 'shows pagination when multiple pages exist' do
      get '/changelog'
      expect(response.body).to include('Page 1 of 37')
      expect(response.body).to include('Older')
    end

    it 'uses disabled buttons for page boundaries' do
      get '/changelog'
      expect(response.body).to include('<button')
      expect(response.body).to include('disabled')
      expect(response.body).to include('page-link--disabled')
    end

    it 'filters out internal/noise commits' do
      get '/changelog'
      expect(response.body).not_to include('builder/planner memory')
      expect(response.body).not_to include('review plans')
    end

    it 'categorizes spec-only commits as update, not feature' do
      get '/changelog'
      # "Add request specs for login flow" should be :update, not :feature
      expect(response.body).not_to include('xw-changelog__badge--feature">Feature</span>')
      # The feature badge should NOT appear for spec commits
      # Only "Add solve timer..." is a true feature
    end

    it 'includes the changelog stylesheet' do
      get '/changelog'
      expect(response.body).to include('changelog')
    end
  end

  # -------------------------------------------------------------------------
  # GET /changelog?page=2 — pagination
  # -------------------------------------------------------------------------
  describe 'GET /changelog?page=2' do
    before do
      Rails.cache.delete("changelog_page_2")
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'forwards the page parameter' do
      get '/changelog', params: { page: 2 }
      expect(response).to have_http_status(:ok)
      expect(HTTParty).to have_received(:get).with(
        anything,
        hash_including(query: hash_including(page: 2))
      )
    end

    it 'shows both Newer and Older links' do
      get '/changelog', params: { page: 2 }
      expect(response.body).to include(changelog_path(page: 1))
      expect(response.body).to include(changelog_path(page: 3))
    end
  end

  # -------------------------------------------------------------------------
  # GET /changelog — API failure fallback
  # -------------------------------------------------------------------------
  describe 'GET /changelog when API is unavailable' do
    before do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout, 'execution expired')
    end

    it 'renders the fallback message' do
      get '/changelog'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('github.com/doshea/xword/commits')
    end
  end

  # -------------------------------------------------------------------------
  # Caching
  # -------------------------------------------------------------------------
  describe 'caching' do
    let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'caches results and does not call GitHub API twice' do
      get '/changelog'
      get '/changelog'
      expect(HTTParty).to have_received(:get).once
    end
  end

  # -------------------------------------------------------------------------
  # GithubChangelogService unit behavior (exercised through requests)
  # -------------------------------------------------------------------------
  describe 'noise filtering' do
    it 'skips persona memory commits' do
      expect(GithubChangelogService.skip_commit?("Update builder/planner memory and add review plans")).to be true
    end

    it 'skips CLAUDE.md commits' do
      expect(GithubChangelogService.skip_commit?("Update CLAUDE.md: remove stale sections")).to be true
    end

    it 'skips merge commits' do
      expect(GithubChangelogService.skip_commit?("Merge branch 'feature' into master")).to be true
      expect(GithubChangelogService.skip_commit?("Merge pull request #42 from doshea/feature")).to be true
    end

    it 'does not skip real commits' do
      expect(GithubChangelogService.skip_commit?("Fix edit page save button")).to be false
      expect(GithubChangelogService.skip_commit?("Add solve timer feature")).to be false
    end
  end
end
