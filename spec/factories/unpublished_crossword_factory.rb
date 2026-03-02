FactoryBot.define do
  factory :unpublished_crossword do
    rows { 5 }
    cols { 5 }
    title { Faker::Lorem.characters(number: (Crosswordable::MIN_TITLE_LENGTH..Crosswordable::MAX_TITLE_LENGTH).to_a.sample) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }

    user

    trait :with_words do
      potential_words { %w[HELLO WORLD] }
    end
  end
end
