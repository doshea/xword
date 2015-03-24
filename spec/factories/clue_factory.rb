# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text             default("ENTER CLUE")
#  difficulty :integer          default(1)
#  user_id    :integer
#  word_id    :integer
#  phrase_id  :integer
#

FactoryGirl.define do
  #THESE CLUES NEED ASSOCIATED WORDS
  factory :clue, class: Clue do
    difficulty { rand(5) + 1}
    content Faker::Lorem.words(7).join(' ')
  end
  factory :min_clue, class: Clue do
    content 'this is a clue'
  end
  factory :easy_clue, class: Clue do
    content 'this is an easy clue'
    difficulty 1
  end
  factory :hard_clue, class: Clue do
    content 'this is a difficult clue'
    difficulty 5
  end
end
