# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default(""), not null
#  is_complete  :boolean          default(FALSE), not null
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  team         :boolean          default(FALSE), not null
#  key          :string(255)
#  solved_at    :datetime
#

FactoryGirl.define do
end
