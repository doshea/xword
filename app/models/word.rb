# == Schema Information
#
# Table name: words
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'open-uri'

class Word < ApplicationRecord
  scope :desc_length, -> {order('length(content) DESC')}

  include PgSearch::Model
  pg_search_scope :starts_with,
                  against: :content,
                  using: {
                    tsearch: {prefix: true}
                  }

  has_many :clues, inverse_of: :word
  has_many :phrases, -> { distinct }, through: :clues
  has_many :across_cells, through: :clues
  has_many :down_cells, through: :clues
  has_many :across_crosswords, through: :across_cells, source: :crossword
  has_many :down_crosswords, through: :down_cells, source: :crossword

  def crosswords
    Crossword.where(id: across_crosswords.select(:id))
             .or(Crossword.where(id: down_crosswords.select(:id)))
  end

  def crosswords_by_title
    crosswords.reorder(:title)
  end
  self.per_page = 50

  validates_uniqueness_of :content

  def self.word_match(pattern)
    sanitized = ERB::Util.url_encode(pattern.to_s[0, 100])
    url = "https://www.a2zwordfinder.com/cgi-bin/crossword.cgi?SearchType=Crossword&Pattern=#{sanitized}&Search=Find+Words"
    page = Nokogiri::HTML(URI.open(url, open_timeout: 10, read_timeout: 10))
    results = page.css('font[face=Courier]').text.split(", \n")
    results
  rescue StandardError => e
    Rails.logger.error("Word.word_match failed for pattern '#{pattern}': #{e.class} — #{e.message}")
    []
  end
end

