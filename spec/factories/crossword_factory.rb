# == Schema Information
#
# Table name: crosswords
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("Untitled"), not null
#  letters        :text             default(""), not null
#  description    :text
#  rows           :integer          default(15), not null
#  cols           :integer          default(15), not null
#  published      :boolean          default(FALSE), not null
#  date_published :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :unpublished_crossword do
    published false
  end

  factory :published_crossword do
    published true
  end
end
