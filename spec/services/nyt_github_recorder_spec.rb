RSpec.describe NytGithubRecorder do
  let(:puzzle_date) { Date.new(2024, 3, 5) }
  let(:puzzle_json) { '{"title":"NY Times, Tue, Mar 05, 2024","grid":["A","B"]}' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GITHUB_USERNAME').and_return('testuser')
    allow(ENV).to receive(:[]).with('GITHUB_PASSWORD').and_return('testpass')
  end

  describe '.smart_record' do
    it 'parses the JSON and delegates to record_on_github' do
      allow(described_class).to receive(:record_on_github)
      described_class.smart_record(puzzle_json)

      expect(described_class).to have_received(:record_on_github).with(
        puzzle_json,
        puzzle_date
      )
    end
  end

  describe '.record_date_on_github' do
    it 'fetches from xwordinfo then delegates to record_on_github' do
      xword_response = instance_double(HTTParty::Response, body: puzzle_json)
      allow(NytPuzzleFetcher).to receive(:from_xwordinfo).and_return(xword_response)
      allow(described_class).to receive(:record_on_github)

      described_class.record_date_on_github(puzzle_date)

      expect(NytPuzzleFetcher).to have_received(:from_xwordinfo).with(puzzle_date)
      expect(described_class).to have_received(:record_on_github).with(xword_response, puzzle_date)
    end
  end

  describe '.record_on_github' do
    let(:put_response) { instance_double(HTTParty::Response, success?: true) }

    before { allow(HTTParty).to receive(:put).and_return(put_response) }

    it 'returns nil when puzzle_json is nil' do
      expect(described_class.record_on_github(nil, puzzle_date)).to be_nil
    end

    it 'PUTs to the correct GitHub API URL with zero-padded path' do
      described_class.record_on_github(puzzle_json, puzzle_date)

      expect(HTTParty).to have_received(:put).with(
        'https://api.github.com/repos/doshea/nyt_crosswords/contents/2024/03/05.json',
        hash_including(timeout: 10)
      )
    end

    it 'sends Base64-encoded content in the body' do
      described_class.record_on_github(puzzle_json, puzzle_date)

      expect(HTTParty).to have_received(:put).with(
        anything,
        hash_including(
          body: a_string_including(Base64.strict_encode64(puzzle_json))
        )
      )
    end

    it 'includes a commit message with formatted date' do
      described_class.record_on_github(puzzle_json, puzzle_date)

      expect(HTTParty).to have_received(:put).with(
        anything,
        hash_including(
          body: a_string_including('NYT puzzle for Tue, Mar 05, 2024')
        )
      )
    end

    it 'uses basic_auth from ENV vars' do
      described_class.record_on_github(puzzle_json, puzzle_date)

      expect(HTTParty).to have_received(:put).with(
        anything,
        hash_including(
          basic_auth: { username: 'testuser', password: 'testpass' }
        )
      )
    end
  end
end
