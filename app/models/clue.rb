# == Schema Information
#
# Table name: clues
#
#  id         :integer          not null, primary key
#  content    :text
#  difficulty :integer
#  user_id    :integer
#  word_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Clue < ActiveRecord::Base
  attr_accessible :content, :difficulty, :user_id, :word_id, :clue_instance_ids, :crossword_ids

  has_many :clue_instances, :inverse_of => :clue
  belongs_to :word, :inverse_of => :clues
  belongs_to :user, :inverse_of => :clues
  has_many :crosswords, :through => :clue_instances, :inverse_of => :clues

end