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

  include PgSearch
  pg_search_scope :starts_with,
                  against: :content,
                  using: {
                    tsearch: {prefix: true}
                  }

  has_many :clues, inverse_of: :word
  # has_and_belongs_to_many :crosswords
end

