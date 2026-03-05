# == Schema Information
#
# Table name: crosswords
#
#  id          :integer          not null, primary key
#  title       :string(255)      default("Untitled"), not null
#  letters     :text             default(""), not null
#  description :text
#  rows        :integer          default(15), not null
#  cols        :integer          default(15), not null
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  circled     :boolean          default(FALSE)
#  preview     :text
#

FactoryBot.define do
  factory :crossword do
    rows { 5 }
    cols { 5 }
    title { Faker::Lorem.characters(number: (Crossword::MIN_TITLE_LENGTH..Crossword::MAX_TITLE_LENGTH).to_a.sample) }
    # letters { Faker::Lorem.characters(number: rows * cols) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }

    user

    trait :with_fake_solution do
      letters { Faker::Lorem.characters(number: area) }
    end

    # Legacy alias — base factory is now 5×5, so :smaller is a no-op.
    # Kept to avoid breaking existing specs that reference it.
    trait :smaller do
      rows { 5 }
      cols { 5 }
    end

    #from http://www.goobix.com/crosswords/0505/4/
    factory :predefined_five_by_five do
      #Should have 'AMIGO', 'VOLOW', 'ANION', 'IDOSE', 'LONER'
      #and 'AVAIL', 'MONDO', 'ILION', 'GOOSE', 'OWNER'
      rows { 5 }
      cols { 5 }
      title { 'Predefined Puzzle' }

      after(:create) do |crossword|
        crossword.set_contents('AMIGOVOLOWANIONIDOSELONER')
        crossword.set_clue(true, 1, 'A male friend')
        crossword.set_clue(true, 6, 'To baptize')
        crossword.set_clue(true, 7, 'A negative ion')
        crossword.set_clue(true, 8, 'A sugar')
        crossword.set_clue(true, 9, 'A solitary person')
        crossword.set_clue(false, 1, 'Benefit; result')
        crossword.set_clue(false, 2, 'A Zen question and answer method; extreme')
        crossword.set_clue(false, 3, 'Ancient Troy')
        crossword.set_clue(false, 4, "A water fowl; a pinch to the rear; tailor's iron")
        crossword.set_clue(false, 5, 'A possesser')
      end

      # Rebus variant: cell 0 has answer "AM" (multi-char), stored as first-char
      # placeholder "A" in letters[0] and full content in rebus_map["0"].
      trait :rebus do
        after(:create) do |cw|
          cw.update!(rebus_map: { '0' => 'AM' })
          cw.cells.order(:index).first.update!(letter: 'AM')
        end
      end
    end

  end
end
