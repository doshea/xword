# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Word < ActiveRecord::Base
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
  # TODO figure out whether I'm going to implement this and whether I can use the source: option rather than class_name
  # What is the difference between source: and class_name: ?
  has_and_belongs_to_many :potential_crosswords, class_name: 'Crossword', join_table: :potential_crosswords_potential_words

  self.per_page = 50

  validates_uniqueness_of :content

  def self.word_match(pattern)
    url = "http://www.a2zwordfinder.com/cgi-bin/crossword.cgi?SearchType=Crossword&Pattern=#{pattern}&Search=Find+Words"
    page = Nokogiri::HTML(open(url))
    results = page.css('font[face=Courier]').text.split(", \n")
    results
  end
end

