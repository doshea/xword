RSpec.describe GithubChangelogService do
  let(:github_commits) do
    [
      {
        "sha" => "abc1234567890abcdef",
        "commit" => {
          "message" => "Add solve timer and next-puzzle suggestion on win\n\nCo-Authored-By: Someone",
          "author" => { "name" => "Dylan", "date" => "2026-03-04T22:17:22Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/abc1234"
      },
      {
        "sha" => "def5678901234567890",
        "commit" => {
          "message" => "Fix edit page save button: ghost style",
          "author" => { "name" => "Dylan", "date" => "2026-03-04T21:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/def5678"
      },
      {
        "sha" => "ghi9012345678901234",
        "commit" => {
          "message" => "Rebuild stats page as 6-section community dashboard",
          "author" => { "name" => "Dylan", "date" => "2026-03-03T18:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/ghi9012"
      },
      {
        "sha" => "skip111222333444555",
        "commit" => {
          "message" => "Update builder/planner memory and add review plans",
          "author" => { "name" => "Dylan", "date" => "2026-03-03T17:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/skip111"
      },
      {
        "sha" => "jkl3456789012345678",
        "commit" => {
          "message" => "Polish changelog: loading, prefix stripping",
          "author" => { "name" => "Dylan", "date" => "2026-03-02T12:00:00Z" }
        },
        "html_url" => "https://github.com/doshea/xword/commit/jkl3456"
      }
    ]
  end

  let(:link_header) { '<https://api.github.com/repos/doshea/xword/commits?page=37>; rel="last"' }

  let(:success_response) do
    instance_double(
      HTTParty::Response,
      success?: true,
      parsed_response: github_commits,
      headers: { "link" => link_header }
    )
  end

  let(:failure_response) do
    instance_double(HTTParty::Response, success?: false)
  end

  # -------------------------------------------------------------------------
  # .fetch
  # -------------------------------------------------------------------------
  describe '.fetch' do
    before do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'returns a hash with commits, page, per_page, and total_pages' do
      result = described_class.fetch(page: 1)
      expect(result).to include(:commits, :page, :per_page, :total_pages)
      expect(result[:page]).to eq 1
      expect(result[:per_page]).to eq 20
      expect(result[:total_pages]).to eq 37
    end

    it 'filters out skipped commits' do
      result = described_class.fetch(page: 1)
      messages = result[:commits].map { |c| c[:message] }
      expect(messages).not_to include(a_string_matching(/memory/i))
    end

    it 'extracts only the first line of multi-line messages' do
      result = described_class.fetch(page: 1)
      feature_commit = result[:commits].find { |c| c[:category] == :feature }
      expect(feature_commit[:message]).not_to include('Co-Authored-By')
    end

    it 'truncates SHA to 7 characters' do
      result = described_class.fetch(page: 1)
      result[:commits].each { |c| expect(c[:sha].length).to eq 7 }
    end

    it 'parses date to a Date object' do
      result = described_class.fetch(page: 1)
      result[:commits].each { |c| expect(c[:date]).to be_a(Date) }
    end

    it 'returns nil on HTTP failure' do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_return(failure_response)
      expect(described_class.fetch(page: 1)).to be_nil
    end

    it 'returns nil on exception' do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout, 'execution expired')
      expect(described_class.fetch(page: 1)).to be_nil
    end

    it 'caches results' do
      memory_store = ActiveSupport::Cache::MemoryStore.new
      allow(Rails).to receive(:cache).and_return(memory_store)

      described_class.fetch(page: 1)
      described_class.fetch(page: 1)
      expect(HTTParty).to have_received(:get).once
    end

    context 'auth header injection' do
      before do
        Rails.cache.delete("changelog_page_1")
        allow(ENV).to receive(:[]).and_call_original
      end

      it 'includes basic_auth when env vars are present' do
        allow(ENV).to receive(:[]).with('GITHUB_USERNAME').and_return('user')
        allow(ENV).to receive(:[]).with('GITHUB_PASSWORD').and_return('pass')
        # Also stub .present? behavior via the [] stub + ActiveSupport
        allow(ENV).to receive(:fetch).and_call_original

        described_class.fetch(page: 1)
        expect(HTTParty).to have_received(:get).with(
          anything,
          hash_including(basic_auth: { username: 'user', password: 'pass' })
        )
      end

      it 'omits basic_auth when env vars are blank' do
        allow(ENV).to receive(:[]).with('GITHUB_USERNAME').and_return(nil)
        allow(ENV).to receive(:[]).with('GITHUB_PASSWORD').and_return(nil)

        described_class.fetch(page: 1)
        expect(HTTParty).to have_received(:get).with(
          anything,
          hash_not_including(:basic_auth)
        )
      end
    end
  end

  # -------------------------------------------------------------------------
  # .skip_commit?
  # -------------------------------------------------------------------------
  describe '.skip_commit?' do
    it 'skips persona memory commits' do
      expect(described_class.skip_commit?('Update builder/planner memory')).to be true
      expect(described_class.skip_commit?('Update deployer memory')).to be true
    end

    it 'skips shared.md commits' do
      expect(described_class.skip_commit?('Update shared.md with deploy log')).to be true
    end

    it 'skips CLAUDE.md commits' do
      expect(described_class.skip_commit?('Update CLAUDE.md: remove stale sections')).to be true
    end

    it 'skips merge commits' do
      expect(described_class.skip_commit?("Merge branch 'feature' into master")).to be true
      expect(described_class.skip_commit?('Merge pull request #42 from doshea/feature')).to be true
    end

    it 'skips memory files commits' do
      expect(described_class.skip_commit?('Update memory files')).to be true
    end

    it 'skips review plan commits' do
      expect(described_class.skip_commit?('Add review plans for phase 2')).to be true
    end

    it 'does not skip real commits' do
      expect(described_class.skip_commit?('Fix edit page save button')).to be false
      expect(described_class.skip_commit?('Add solve timer feature')).to be false
      expect(described_class.skip_commit?('Rebuild stats page')).to be false
    end
  end

  # -------------------------------------------------------------------------
  # categorize (private — tested via .fetch output)
  # -------------------------------------------------------------------------
  describe 'categorization' do
    before do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'categorizes Fix commits as :fix' do
      result = described_class.fetch(page: 1)
      fix_commit = result[:commits].find { |c| c[:message].include?('Edit page') }
      expect(fix_commit[:category]).to eq :fix
    end

    it 'categorizes Add commits as :feature' do
      result = described_class.fetch(page: 1)
      feature_commit = result[:commits].find { |c| c[:message].include?('Solve timer') }
      expect(feature_commit[:category]).to eq :feature
    end

    it 'categorizes Rebuild/Modernize/Refactor/Extract as :improve' do
      result = described_class.fetch(page: 1)
      improve_commit = result[:commits].find { |c| c[:message].include?('Stats page') }
      expect(improve_commit[:category]).to eq :improve
    end

    it 'categorizes Polish commits as :polish' do
      result = described_class.fetch(page: 1)
      polish_commit = result[:commits].find { |c| c[:message].include?('Changelog') }
      expect(polish_commit[:category]).to eq :polish
    end

    it 'categorizes spec-only commits as :update, not :feature' do
      spec_commits = [
        { "sha" => "spec123456789012345",
          "commit" => { "message" => "Add test coverage for login flow",
                        "author" => { "date" => "2026-03-01T10:00:00Z" } },
          "html_url" => "https://github.com/doshea/xword/commit/spec123" }
      ]
      spec_response = instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: spec_commits,
        headers: {}
      )
      Rails.cache.delete("changelog_page_2")
      allow(HTTParty).to receive(:get).and_return(spec_response)

      result = described_class.fetch(page: 2)
      expect(result[:commits].first[:category]).to eq :update
    end

    it 'categorizes fix+spec commits as :fix (fix wins)' do
      fix_spec_commits = [
        { "sha" => "fixs123456789012345",
          "commit" => { "message" => "Fix rspec deprecation warnings",
                        "author" => { "date" => "2026-03-01T10:00:00Z" } },
          "html_url" => "https://github.com/doshea/xword/commit/fixs123" }
      ]
      fix_response = instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: fix_spec_commits,
        headers: {}
      )
      Rails.cache.delete("changelog_page_3")
      allow(HTTParty).to receive(:get).and_return(fix_response)

      result = described_class.fetch(page: 3)
      expect(result[:commits].first[:category]).to eq :fix
    end
  end

  # -------------------------------------------------------------------------
  # strip_category_prefix (private — tested via .fetch output)
  # -------------------------------------------------------------------------
  describe 'prefix stripping' do
    before do
      Rails.cache.delete("changelog_page_1")
      allow(HTTParty).to receive(:get).and_return(success_response)
    end

    it 'strips "Fix " from :fix messages and capitalizes' do
      result = described_class.fetch(page: 1)
      fix_commit = result[:commits].find { |c| c[:category] == :fix }
      expect(fix_commit[:message]).to eq 'Edit page save button: ghost style'
    end

    it 'strips "Add " from :feature messages and capitalizes' do
      result = described_class.fetch(page: 1)
      feature_commit = result[:commits].find { |c| c[:category] == :feature }
      expect(feature_commit[:message]).to eq 'Solve timer and next-puzzle suggestion on win'
    end

    it 'strips "Rebuild " from :improve messages and capitalizes' do
      result = described_class.fetch(page: 1)
      improve_commit = result[:commits].find { |c| c[:category] == :improve }
      expect(improve_commit[:message]).to eq 'Stats page as 6-section community dashboard'
    end

    it 'strips "Polish " from :polish messages and capitalizes' do
      result = described_class.fetch(page: 1)
      polish_commit = result[:commits].find { |c| c[:category] == :polish }
      expect(polish_commit[:message]).to eq 'Changelog: loading, prefix stripping'
    end

    it 'does not strip anything for :update messages' do
      update_commits = [
        { "sha" => "upd1234567890123456",
          "commit" => { "message" => "Show loading spinner on nav clicks",
                        "author" => { "date" => "2026-03-01T10:00:00Z" } },
          "html_url" => "https://github.com/doshea/xword/commit/upd1234" }
      ]
      update_response = instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: update_commits,
        headers: {}
      )
      Rails.cache.delete("changelog_page_4")
      allow(HTTParty).to receive(:get).and_return(update_response)

      result = described_class.fetch(page: 4)
      expect(result[:commits].first[:message]).to eq 'Show loading spinner on nav clicks'
    end
  end

  # -------------------------------------------------------------------------
  # parse_last_page (private — tested via .fetch output)
  # -------------------------------------------------------------------------
  describe 'pagination parsing' do
    before { Rails.cache.delete("changelog_page_1") }

    it 'parses total_pages from the Link header' do
      allow(HTTParty).to receive(:get).and_return(success_response)
      result = described_class.fetch(page: 1)
      expect(result[:total_pages]).to eq 37
    end

    it 'defaults total_pages to current page when no Link header' do
      no_link_response = instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: github_commits,
        headers: {}
      )
      allow(HTTParty).to receive(:get).and_return(no_link_response)
      result = described_class.fetch(page: 1)
      expect(result[:total_pages]).to eq 1
    end

    it 'defaults total_pages to current page when Link header has no rel=last' do
      next_only_response = instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: github_commits,
        headers: { "link" => '<https://api.github.com/repos/doshea/xword/commits?page=2>; rel="next"' }
      )
      allow(HTTParty).to receive(:get).and_return(next_only_response)
      result = described_class.fetch(page: 1)
      expect(result[:total_pages]).to eq 1
    end
  end
end
