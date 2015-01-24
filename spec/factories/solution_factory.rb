# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default(""), not null
#  is_complete  :boolean          default("false"), not null
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  team         :boolean          default("false"), not null
#  key          :string(255)
#  solved_at    :datetime
#

FactoryGirl.define do
end
