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

    trait :with_fake_solution do
      letters { Faker::Lorem.characters(area) }
    end

    # Permits faster testing of size-independent features
    trait :smaller do
      rows {Crossword.random_dimension(15)}
      cols {Crossword.random_dimension(15)}
    end

    #from http://www.goobix.com/crosswords/0505/4/
    factory :predefined_five_by_five do
      #Should have 'AMIGO', 'VOLOW', 'ANION', 'IDOSE', 'LONER'
      #and 'AVAIL', 'MONDO', 'ILION', 'GOOSE', 'OWNER'
      rows 5
      cols 5
      title 'Predefined Puzzle'
      
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
    end

    factory :published_five_by_five do
      #Should have 'AMIGO', 'VOLOW', 'ANION', 'IDOSE', 'LONER'
      #and 'AVAIL', 'MONDO', 'ILION', 'GOOSE', 'OWNER'
      rows 5
      cols 5
      title 'Predefined Puzzle'
      
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
        crossword.publish!
      end
    end

    #from http://www.rinkworks.com/brainfood/p/5box1.shtml
    factory :repeating_five_by_five do
      rows 5
      cols 5
      title 'Repeating Puzzle'

      after(:create) do |crossword|
        crossword.set_contents('WORLDOTHERRHYMELEMMADREAD')
        crossword.set_clue(true, 1, 'complete environment')
        crossword.set_clue(true, 6, 'not this one')
        crossword.set_clue(true, 7, 'poetic device')
        crossword.set_clue(true, 8, 'assumption')
        crossword.set_clue(true, 9, 'foreboding')
        crossword.set_clue(false, 1, 'planet')
        crossword.set_clue(false, 2, 'alien')
        crossword.set_clue(false, 3, 'similar sounder')
        crossword.set_clue(false, 4, "with 'dil', a sticky situation")
        crossword.set_clue(false, 5, 'apprehensive fear')
      end
    end

  end


end
