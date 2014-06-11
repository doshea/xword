# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  letter          :string(255)
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  cell_num        :integer
#  is_void         :boolean          default(FALSE), not null
#  is_across_start :boolean          default(FALSE), not null
#  is_down_start   :boolean          default(FALSE), not null
#  crossword_id    :integer
#  across_clue_id  :integer
#  down_clue_id    :integer
#  created_at      :datetime
#  updated_at      :datetime
#  circled         :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :cell do
    letter {Faker::Lorem.charcters(1)}
    row { Crossword.random_row_or_col }
    col { Crossword.random_row_or_col }
    index { (col..Crossword::MAX_DIMENSION).to_a.sample * (row-1) + col }
    cell_num { (1..index).to_a.sample }

    trait :void do
      is_void true
    end

    trait :with_across_clue do
      is_across_start true
      association across_clue, factory: :clue
    end

    trait :with_down_clue do
      is_down_start true
      association down_clue, factory: :clue
    end

    trait :in_crossword do
      association :crossword, circled: true
    end

    factory :circled_cell do
      circled true
    end
  end
end
