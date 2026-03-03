# == Schema Information
#
# Table name: phrases
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  created_at :datetime
#  updated_at :datetime
#

class Phrase < ApplicationRecord
  has_many :clues, inverse_of: :phrase
  has_many :words, -> { distinct }, through: :clues
  has_many :across_cells, through: :clues
  has_many :down_cells, through: :clues
  has_many :across_crosswords, through: :across_cells, source: :crossword
  has_many :down_crosswords, through: :down_cells, source: :crossword

  validates :content, presence: true, uniqueness: { case_sensitive: false }

  def self.find_or_create_by_content(text)
    stripped = text.strip
    where("LOWER(content) = LOWER(?)", stripped).first_or_create!(content: stripped)
  end

  def crosswords
    (across_crosswords + down_crosswords).uniq
  end

  def crosswords_by_title
    crosswords.sort_by(&:title)
  end
end
