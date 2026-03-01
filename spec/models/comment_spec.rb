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
  context 'associations' do
    it {should belong_to(:user).optional}
    it {should belong_to(:crossword).optional}
    it {should belong_to(:base_comment).class_name('Comment').optional}
    it {should have_many(:replies).class_name('Comment').with_foreign_key('base_comment_id').dependent(:destroy)}
  end

end
