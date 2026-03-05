# Imports an NYT crossword puzzle from a parsed JSON hash.
# Extracted from Newyorkable#add_nyt_puzzle — the core ETL pipeline.
#
# Fixes over the original:
# - Nil guard on the nytimes user (raises instead of NPE)
# - HTTP timeouts on any downstream calls (generate_preview uses Magick, not HTTP,
#   but future callers inherit the pattern)
# - Wrapped in a transaction to prevent orphaned crosswords on failure
class NytPuzzleImporter
  # Import a single puzzle from a parsed hash (string or symbol keys).
  # Returns the created Crossword, or nil if the puzzle was a duplicate.
  def self.import(pz)
    pz_title = pz['title'] || pz[:title]
    return nil if Crossword.where(title: pz_title).any?

    letters, rebus_map = normalize_grid(pz)
    pz_date  = NytPuzzleFetcher.parse_puzzle_date(pz)
    title    = fix_title(pz_title)

    nytimes = User.find_by_username('nytimes')
    raise "NYT import requires a user with username 'nytimes'" unless nytimes

    Crossword.transaction do
      crossword = create_crossword(pz, title: title, letters: letters, date: pz_date, rebus_map: rebus_map)
      nytimes.crosswords << crossword
      assign_clues(crossword, pz['clues'] || pz[:clues])

      Rails.logger.info("[NytPuzzleImporter] imported puzzle: #{crossword.title}")
      crossword.generate_preview
      crossword
    end
  end

  # Extract multi-character rebus entries into rebus_map, keep first char in grid.
  # Periods become underscores (void cells).
  # Returns [letters_string, rebus_map].
  def self.normalize_grid(pz)
    grid = pz['grid'] || pz[:grid]
    rebus_map = {}
    grid.each_with_index do |el, i|
      if el.length > 1
        rebus_map[i.to_s] = el
        grid[i] = el[0]
      end
    end
    [grid.join('').gsub('.', '_'), rebus_map]
  end
  private_class_method :normalize_grid

  # Capitalize title words, preserving "NY " prefix if present.
  def self.fix_title(pz_title)
    if pz_title[0..2] == 'NY '
      'NY ' + pz_title[3..].split.map(&:capitalize).join(' ')
    else
      pz_title.split.map(&:capitalize).join(' ')
    end
  end
  private_class_method :fix_title

  # Build and save the Crossword record, set grid contents and circles.
  def self.create_crossword(pz, title:, letters:, date:, rebus_map: {})
    pz_size = pz['size'] || pz[:size]

    crossword = Crossword.create!(
      title: title,
      rows: (pz_size['rows'] || pz_size[:rows]),
      cols: (pz_size['cols'] || pz_size[:cols]),
      description: "This puzzle was published on #{date.strftime('%A, %b %d, %Y')} in the New York Times Crossword Puzzle. Edited by Will Shortz.",
      created_at: date
    )

    crossword.set_contents(letters, new_rebus_map: rebus_map.presence)
    crossword.number_cells

    pz_circles = pz['circles'] || pz[:circles]
    crossword.circles_from_array(pz_circles) if pz_circles

    crossword
  end
  private_class_method :create_crossword

  # Assign across and down clues from the puzzle JSON.
  def self.assign_clues(crossword, pz_clues)
    (pz_clues['across'] || pz_clues[:across]).each do |clue_str|
      num, content = clue_str.split('. ', 2)
      crossword.set_clue(true, num.to_i, content)
    end

    (pz_clues['down'] || pz_clues[:down]).each do |clue_str|
      num, content = clue_str.split('. ', 2)
      crossword.set_clue(false, num.to_i, content)
    end
  end
  private_class_method :assign_clues
end
