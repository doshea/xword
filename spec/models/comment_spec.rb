# == Schema Information
#
# Table name: comments
#
#  id              :integer          not null, primary key
#  content         :text             not null
#  flagged         :boolean          default(FALSE), not null
#  user_id         :integer
#  crossword_id    :integer
#  base_comment_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

describe Comment do
  let(:user)      { create(:user) }
  let(:crossword) { create(:crossword) }

  context 'associations' do
    it {should belong_to(:user).optional}
    it {should belong_to(:crossword).optional}
    it {should belong_to(:base_comment).class_name('Comment').optional}
    it {should have_many(:replies).class_name('Comment').with_foreign_key('base_comment_id').dependent(:destroy)}
  end

  describe 'MAX_PER_CROSSWORD' do
    it 'is defined as a positive integer' do
      expect(Comment::MAX_PER_CROSSWORD).to be_a(Integer).and be_positive
    end
  end

  describe '#base_crossword' do
    context 'for a top-level comment (has crossword directly)' do
      it 'returns the comment\'s own crossword' do
        comment = create(:comment, user: user, crossword: crossword)
        expect(comment.base_crossword).to eq crossword
      end
    end

    context 'for a reply (no direct crossword, parent has one)' do
      it 'walks up to the parent and returns its crossword' do
        base_comment = create(:comment, user: user, crossword: crossword)
        reply = Comment.create!(content: 'reply', base_comment: base_comment, user: user)
        expect(reply.base_crossword).to eq crossword
      end
    end
  end
end
