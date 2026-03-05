# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text             default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  phrase_id  :integer
#

describe Clue do
  context 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:word).optional }
    it { is_expected.to belong_to(:phrase).optional }
    it { is_expected.to have_many(:across_cells) }
    it { is_expected.to have_many(:down_cells) }
    it { is_expected.to have_many(:across_crosswords).through(:across_cells).source(:crossword) }
    it { is_expected.to have_many(:down_crosswords).through(:down_cells).source(:crossword) }
  end

  describe '#strip_tags (before_save callback)' do
    let(:clue) { Clue.new(content: 'test', difficulty: 1) }

    it 'preserves UTF-8 characters through save' do
      clue.content = "Québéc café"
      clue.save!
      expect(clue.reload.content).to eq("Québéc café")
    end

    it 'preserves ASCII-8BIT input that is valid UTF-8' do
      # Simulate what HTTParty returns: valid UTF-8 bytes with ASCII-8BIT encoding
      raw = "Québéc".dup.force_encoding('ASCII-8BIT')
      clue.content = raw
      clue.save!
      expect(clue.reload.content).to eq("Québéc")
      expect(clue.content.encoding).to eq(Encoding::UTF_8)
    end

    it 'strips HTML while preserving Unicode characters' do
      clue.content = "<b>Café</b> <script>alert('x')</script>"
      clue.save!
      expect(clue.reload.content).to eq("Café alert('x')")
    end

    it 'handles true ISO-8859-1 bytes by transcoding to UTF-8' do
      # "café" in ISO-8859-1: the é is a single byte 0xE9
      raw = "caf\xE9".dup.force_encoding('ASCII-8BIT')
      clue.content = raw
      clue.save!
      expect(clue.reload.content).to eq("café")
    end
  end
end
