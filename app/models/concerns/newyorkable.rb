module Newyorkable
  extend ActiveSupport::Concern

  included do
    #attr_accessible
    #scopes
    #has_many and belongs_to
  end

  def herro
    puts 'herro'
  end

  module ClassMethods

    def add_nyt_puzzle(pz)
      pz_letters = pz['grid'].join('').gsub('.','_')
      begin
        pz_date = Date.parse(pz['title'])
      rescue
        alt_date = pz['date']
        pz_date = Date.strptime(alt_date, '%m/%d/%Y')
      end

      unless Crossword.where(title: pz['title']).any?
        new_nytimes_crossword = Crossword.create(
          title: pz['title'],
          rows: pz['size']['rows'],
          cols: pz['size']['cols'],
          published: true,
          date_published: pz_date,
          description: "This puzzle was published on #{pz_date.strftime('%A, %b %d, %Y')} in the New York Times Crossword Puzzle. Edited by Will Shortz."
        )

        new_nytimes_crossword.link_cells_to_neighbors
        new_nytimes_crossword.letters = pz_letters
        new_nytimes_crossword.set_letters(pz_letters)
        new_nytimes_crossword.number_cells
        new_nytimes_crossword.add_circles_by_array(pz['circles']) if pz['circles']

        nytimes = User.find_by_username('nytimes')

        nytimes.crosswords << new_nytimes_crossword

        #adds the clues
        across_clues = pz['clues']['across']
        down_clues = pz['clues']['down']

        across_clues.each do |across_clue|
          split_clue = across_clue.split('. ', 2)
          new_nytimes_crossword.set_clue(true, split_clue[0].to_i, split_clue[1])
        end

        down_clues.each do |down_clue|
          split_clue = down_clue.split('. ', 2)
          new_nytimes_crossword.set_clue(false, split_clue[0].to_i, split_clue[1])
        end

        puts pz_letters
        puts new_nytimes_crossword.letters
      else
        puts 'That puzzle has already been added! Woo a freebie!'
      end
    end

    def add_latest_nyt_puzzle
      latest = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx")
      Crossword.add_nyt_puzzle(latest)
    end
  end
end