module Newyorkable
  extend ActiveSupport::Concern

  included do
    #attr_accessible
    #scopes
    #has_many and belongs_to
  end

  module ClassMethods

    def add_nyt_puzzle(pz)
      #account for multiples
      pz_letters = pz['grid']

      pz_letters.each_with_index do |el, i|
        if el.length > 1
          pz_letters[i] = '-' #replace with hyphens, not underscores because underscores mean void
        end
      end

      pz_letters = pz_letters.join('').gsub('.','_')
      begin
        pz_date = Date.parse(pz['title'])
      rescue
        alt_date = pz['date']
        pz_date = Date.strptime(alt_date, '%m/%d/%Y')
      end

      unless Crossword.where(title: pz['title']).any?
        #fix the title capitalization
        if pz['title'][0..2] == 'NY '
          fixed_title = 'NY ' + pz['title'][3..-1].split.map(&:capitalize).join(' ')
        else
          fixed_title = pz['title'].split.map(&:capitalize).join(' ')
        end 

        new_nytimes_crossword = Crossword.create(
          title: fixed_title,
          rows: pz['size']['rows'],
          cols: pz['size']['cols'],
          published: true,
          published_at: pz_date,
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

        puts new_nytimes_crossword.letters
        new_nytimes_crossword.generate_preview
      else
        puts 'That puzzle has already been added! Woo a freebie!'
      end
    end

    def add_latest_nyt_puzzle
      latest = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx")
      Crossword.add_nyt_puzzle(latest)
    end

    def get_nyt_from_date(date)
      puzzle_string = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx?date=#{date.month}/#{date.day}/#{date.year}")
    end

    def record_on_github(puzzle_string, date)
      url_stem = 'https://api.github.com'
      repo = 'nyt_puzzle_history'
      username = 'doshea'

      # date_underscores = Date.today.to_s.gsub('-', '_')
      year = date.year
      month = sprintf('%02d', date.month)
      day = sprintf('%02d', date.day)

      auth = {username: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD']}
      create_url = url_stem + "/repos/#{username}/#{repo}/contents/#{year}/#{month}/#{day}.json"

      HTTParty.put(
        create_url,
        basic_auth: auth,
        headers: {"User-Agent" => ENV['GITHUB_USERNAME']},
        body: {
          message: "NYT puzzle for #{date.strftime('%a, %b %d, %Y')}",
          content: Base64.strict_encode64(puzzle_string)
        }.to_json
      )
    end

    def record_latest_nyt_puzzle_on_github
      puzzle_text = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx").to_s
      Crossword.record_on_github(puzzle_text, Date.today)
    end

  end
end