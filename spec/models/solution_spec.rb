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

describe Solution do
  context 'associations' do
    it {should belong_to :user}
    it {should belong_to :crossword}
    it {should have_many(:solution_partnerings).dependent(:destroy)}
    it {should have_many(:teammates).through(:solution_partnerings).source(:user)}
  end

end
