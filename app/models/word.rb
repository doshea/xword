# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Word < ActiveRecord::Base
  attr_accessible :content, :clue_ids, :crossword_ids

  has_many :clues, :inverse_of => :words
  has_many :clue_instances, :through => :clues, :inverse_of => :word
  has_and_belongs_to_many :crosswords
end



