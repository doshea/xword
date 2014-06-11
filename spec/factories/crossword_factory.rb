# == Schema Information
#
# Table name: crosswords
#
#  id           :integer          not null, primary key
#  title        :string(255)      default("Untitled"), not null
#  letters      :text             default(""), not null
#  description  :text
#  rows         :integer          default(15), not null
#  cols         :integer          default(15), not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  circled      :boolean          default(FALSE)
#  preview      :text
#

FactoryGirl.define do
  factory :crossword do
    rows {Crossword.random_dimension}
    cols {Crossword.random_dimension}
    title Faker::Lorem.characters((Crossword::MIN_TITLE_LENGTH..Crossword::MAX_TITLE_LENGTH).to_a.sample)
    # letters {Faker::Lorem.characters(rows * cols)}
    description Faker::Lorem.paragraph(2)

    user

    trait :published do
      published true
      published_at {Time.at(rand * Time.now.to_f)}
    end

  end


end
