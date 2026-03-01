# == Schema Information
#
# Table name: solutions
#
#  id           :integer          not null, primary key
#  letters      :text             default(""), not null
#  is_complete  :boolean          default(FALSE), not null
#  user_id      :integer
#  crossword_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  team         :boolean          default(FALSE), not null
#  key          :string(255)
#  solved_at    :datetime
#

FactoryBot.define do
  factory :solution do
    association :user
    association :crossword

    # Empty letters by default; check_completion will not trigger ('' != crossword.letters)
    letters { '' }
    team    { false }

    # A solved solution with letters matching the crossword
    trait :complete do
      after(:build) { |s| s.letters = s.crossword.letters }
    end

    trait :team do
      team { true }
    end
  end
end
