# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

describe Word do
  context 'associations' do
    it {should have_many :clues}
    it {should have_many :across_cells}
    it {should have_many :down_cells}
    it {should have_many(:across_crosswords).through(:across_cells).source(:crossword) }
    it {should have_many(:down_crosswords).through(:down_cells).source(:crossword) }
  end

  describe '.word_match' do
    it 'returns empty array when external service raises an error' do
      allow(URI).to receive(:open).and_raise(SocketError.new('getaddrinfo: nodename nor servname provided'))
      expect(Word.word_match('TEST')).to eq []
    end

    it 'returns empty array on connection timeout' do
      allow(URI).to receive(:open).and_raise(Net::OpenTimeout.new('execution expired'))
      expect(Word.word_match('TEST')).to eq []
    end

    it 'returns empty array on HTTP error' do
      allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('503 Service Unavailable', StringIO.new))
      expect(Word.word_match('TEST')).to eq []
    end

    it 'logs the error' do
      allow(URI).to receive(:open).and_raise(SocketError.new('connection failed'))
      expect(Rails.logger).to receive(:error).with(/Word\.word_match failed.*SocketError.*connection failed/)
      Word.word_match('TEST')
    end
  end
end
