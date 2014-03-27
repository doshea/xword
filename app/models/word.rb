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

  scope :desc_length, -> {order('length(content) DESC')}

  include PgSearch
  pg_search_scope :starts_with,
                  against: :content,
                  using: {
                    tsearch: {prefix: true}
                  }

  has_many :clues, inverse_of: :word
  has_many :across_cells, through: :clues
  has_many :down_cells, through: :clues
  has_many :across_crosswords, through: :across_cells, source: :crossword
  has_many :down_crosswords, through: :down_cells, source: :crossword

  has_and_belongs_to_many :potential_crosswords, class_name: 'Crossword', join_table: :potential_crosswords_potential_words

  self.per_page = 50

  validates_uniqueness_of :content
end

