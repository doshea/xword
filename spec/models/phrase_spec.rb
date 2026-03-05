# == Schema Information
#
# Table name: phrases
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  created_at :datetime
#  updated_at :datetime
#

describe Phrase do
  describe 'associations' do
    it { is_expected.to have_many(:clues).inverse_of(:phrase) }
    it { is_expected.to have_many(:words).through(:clues) }
    it { is_expected.to have_many(:across_cells).through(:clues) }
    it { is_expected.to have_many(:down_cells).through(:clues) }
    it { is_expected.to have_many(:across_crosswords).through(:across_cells).source(:crossword) }
    it { is_expected.to have_many(:down_crosswords).through(:down_cells).source(:crossword) }
  end

  describe 'validations' do
    subject { Phrase.create!(content: 'test phrase') }

    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:content).case_insensitive }
  end

  describe '.find_or_create_by_content' do
    it 'creates a new phrase when none exists' do
      expect { Phrase.find_or_create_by_content('Norse god of wisdom') }
        .to change(Phrase, :count).by(1)
    end

    it 'returns the existing phrase when content matches (case-insensitive)' do
      original = Phrase.find_or_create_by_content('Norse god of wisdom')
      found = Phrase.find_or_create_by_content('NORSE GOD OF WISDOM')
      expect(found).to eq(original)
    end

    it 'preserves the original casing of the first insertion' do
      Phrase.find_or_create_by_content('Norse god of wisdom')
      found = Phrase.find_or_create_by_content('NORSE GOD OF WISDOM')
      expect(found.content).to eq('Norse god of wisdom')
    end

    it 'strips leading and trailing whitespace' do
      phrase = Phrase.find_or_create_by_content('  A male friend  ')
      expect(phrase.content).to eq('A male friend')
    end

    it 'finds an existing phrase even when input has extra whitespace' do
      original = Phrase.find_or_create_by_content('A male friend')
      found = Phrase.find_or_create_by_content('  A male friend  ')
      expect(found).to eq(original)
    end
  end

  describe '#crosswords_by_title' do
    it 'returns crosswords sorted by title' do
      cw = create(:predefined_five_by_five)
      cw.generate_words_and_link_clues

      phrase = cw.across_clues.first.phrase
      expect(phrase).to be_present
      expect(phrase.crosswords_by_title).to eq(phrase.crosswords.sort_by(&:title))
    end
  end
end
