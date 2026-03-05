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
  has_many :clues, inverse_of: :phrase, dependent: :nullify
  has_many :words, -> { distinct }, through: :clues
  has_many :across_cells, through: :clues
  has_many :down_cells, through: :clues
  has_many :across_crosswords, through: :across_cells, source: :crossword
  has_many :down_crosswords, through: :down_cells, source: :crossword

  validates :content, presence: true, uniqueness: { case_sensitive: false }

  def self.find_or_create_by_content(text)
    stripped = text.strip
    where("LOWER(content) = LOWER(?)", stripped).first_or_create!(content: stripped)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    where("LOWER(content) = LOWER(?)", stripped).first!
  end

  def crosswords
    Crossword.where(id: across_crosswords.select(:id))
             .or(Crossword.where(id: down_crosswords.select(:id)))
  end

  def crosswords_by_title
    crosswords.includes(:user).order(:title)
  end
end
