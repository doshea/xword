RSpec.describe NytPuzzleFetcher do
  describe '.parse_puzzle_date' do
    it 'parses date from the title string' do
      pz = { 'title' => 'NY Times, Mon, Jan 01, 2024' }
      expect(described_class.parse_puzzle_date(pz)).to eq Date.new(2024, 1, 1)
    end

    it 'falls back to the date field when title is unparseable' do
      pz = { 'title' => 'Untitled', 'date' => '01/15/2024' }
      expect(described_class.parse_puzzle_date(pz)).to eq Date.new(2024, 1, 15)
    end

    it 'works with symbol keys' do
      pz = { title: 'NY Times, Fri, Dec 25, 2020' }
      expect(described_class.parse_puzzle_date(pz)).to eq Date.new(2020, 12, 25)
    end

    it 'falls back to date field with symbol keys' do
      pz = { title: 'Untitled', date: '07/04/2023' }
      expect(described_class.parse_puzzle_date(pz)).to eq Date.new(2023, 7, 4)
    end

    it 'raises ArgumentError when neither title nor date parses' do
      pz = { 'title' => 'Untitled', 'date' => 'not-a-date' }
      expect { described_class.parse_puzzle_date(pz) }.to raise_error(ArgumentError)
    end

    it 'raises when date field is missing and title is unparseable' do
      pz = { 'title' => 'Untitled' }
      expect { described_class.parse_puzzle_date(pz) }.to raise_error(TypeError)
    end
  end

  describe '.from_github' do
    let(:response) { instance_double(HTTParty::Response, body: '{"grid":["A"]}') }

    before { allow(HTTParty).to receive(:get).and_return(response) }

    it 'constructs the correct URL with zero-padded month and day' do
      described_class.from_github(Date.new(2024, 3, 5))
      expect(HTTParty).to have_received(:get).with(
        'https://raw.githubusercontent.com/doshea/nyt_crosswords/master/2024/03/05.json',
        hash_including(timeout: 10)
      )
    end

    it 'defaults to today when no date given' do
      described_class.from_github
      today = Date.today
      expected_url = "https://raw.githubusercontent.com/doshea/nyt_crosswords/master/#{today.year}/#{'%02d' % today.month}/#{'%02d' % today.day}.json"
      expect(HTTParty).to have_received(:get).with(expected_url, anything)
    end

    it 'returns the response object' do
      result = described_class.from_github(Date.new(2024, 1, 1))
      expect(result).to eq response
    end

    it 'forces UTF-8 encoding on ASCII-8BIT response bodies' do
      ascii_body = '{"clue":"caf\xC3\xA9"}'.dup.force_encoding('ASCII-8BIT')
      raw_response = instance_double(HTTParty::Response, body: ascii_body)
      allow(HTTParty).to receive(:get).and_return(raw_response)

      described_class.from_github(Date.new(2024, 1, 1))
      expect(ascii_body.encoding).to eq Encoding::UTF_8
    end

    it 'leaves already UTF-8 bodies untouched' do
      utf8_body = '{"clue":"hello"}'
      raw_response = instance_double(HTTParty::Response, body: utf8_body)
      allow(HTTParty).to receive(:get).and_return(raw_response)

      described_class.from_github(Date.new(2024, 1, 1))
      expect(utf8_body.encoding).to eq Encoding::UTF_8
    end
  end

  describe '.from_xwordinfo' do
    let(:response) { instance_double(HTTParty::Response, body: '{"grid":["A"]}') }

    before { allow(HTTParty).to receive(:get).and_return(response) }

    it 'constructs the correct URL without zero-padding' do
      described_class.from_xwordinfo(Date.new(2024, 3, 5))
      expect(HTTParty).to have_received(:get).with(
        'http://www.xwordinfo.com/JSON/Data.aspx?date=3/5/2024',
        hash_including(timeout: 10)
      )
    end

    it 'defaults to today when no date given' do
      described_class.from_xwordinfo
      today = Date.today
      expected_url = "http://www.xwordinfo.com/JSON/Data.aspx?date=#{today.month}/#{today.day}/#{today.year}"
      expect(HTTParty).to have_received(:get).with(expected_url, anything)
    end

    it 'returns the response object' do
      result = described_class.from_xwordinfo(Date.new(2024, 1, 1))
      expect(result).to eq response
    end
  end
end
