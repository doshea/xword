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

FactoryGirl.define do
  factory :comment do
    content {Faker::Lorem.sentences(3)}
  end
end
