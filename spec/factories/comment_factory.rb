# == Schema Information
#
# Table name: comments
#
#  id              :integer          not null, primary key
#  content         :string(255)      not null
#  flagged         :boolean          default(FALSE), not null
#  user_id         :integer
#  crossword_id    :integer
#  base_comment_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
end
