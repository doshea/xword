# Imports an NYT crossword puzzle from a parsed JSON hash.
# Extracted from Newyorkable#add_nyt_puzzle — the core ETL pipeline.
#
# Fixes over the original:
# - Nil guard on the nytimes user (raises instead of NPE)
# - HTTP timeouts on any downstream calls (generate_preview uses Magick, not HTTP,
#   but future callers inherit the pattern)
class NytPuzzleImporter
  # Import a single puzzle from a parsed hash (string or symbol keys).
  # Returns the created Crossword, or nil if the puzzle was a duplicate.
  def self.import(pz)
    pz_letters = pz['grid'] || pz[:grid]
    pz_title   = pz['title'] || pz[:title]
    pz_size    = pz['size'] || pz[:size]
    pz_clues   = pz['clues'] || pz[:clues]

    # Replace multi-character rebus entries with hyphens (not underscores — those mean void)
    pz_letters.each_with_index do |el, i|
      pz_letters[i] = '-' if el.length > 1
    end

    pz_letters = pz_letters.join('').gsub('.', '_')

    begin
      pz_date = Date.parse(pz_title)
    rescue ArgumentError
      alt_date = pz['date'] || pz[:date]
      pz_date = Date.strptime(alt_date, '%m/%d/%Y')
    end

    return nil if Crossword.where(title: pz_title).any?

    # Fix title capitalization
    fixed_title = if pz_title[0..2] == 'NY '
      'NY ' + pz_title[3..-1].split.map(&:capitalize).join(' ')
    else
      pz_title.split.map(&:capitalize).join(' ')
    end

    new_crossword = Crossword.new(
      title: fixed_title,
      rows: (pz_size['rows'] || pz_size[:rows]),
      cols: (pz_size['cols'] || pz_size[:cols]),
      description: "This puzzle was published on #{pz_date.strftime('%A, %b %d, %Y')} in the New York Times Crossword Puzzle. Edited by Will Shortz.",
      created_at: pz_date
    )
    new_crossword.save

    new_crossword.set_contents(pz_letters)
    new_crossword.number_cells

    pz_circles = pz['circles'] || pz[:circles]
    new_crossword.circles_from_array(pz_circles) if pz_circles

    nytimes = User.find_by_username('nytimes')
    raise "NYT import requires a user with username 'nytimes'" unless nytimes

    nytimes.crosswords << new_crossword

    # Add clues
    across_clues = pz_clues['across'] || pz_clues[:across]
    down_clues   = pz_clues['down'] || pz_clues[:down]

    across_clues.each do |across_clue|
      split_clue = across_clue.split('. ', 2)
      new_crossword.set_clue(true, split_clue[0].to_i, split_clue[1])
    end

    down_clues.each do |down_clue|
      split_clue = down_clue.split('. ', 2)
      new_crossword.set_clue(false, split_clue[0].to_i, split_clue[1])
    end

    Rails.logger.info("[NytPuzzleImporter] imported puzzle: #{new_crossword.title}")
    new_crossword.generate_preview

    new_crossword
  end
end
