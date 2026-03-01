# == Schema Information
#
# Table name: crosswords
#
#  id          :integer          not null, primary key
#  title       :string(255)      default("Untitled"), not null
#  letters     :text             default(""), not null
#  description :text
#  rows        :integer          default(15), not null
#  cols        :integer          default(15), not null
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  circled     :boolean          default(FALSE)
#  preview     :text
#

class Crossword < ApplicationRecord
  include Crosswordable, Publishable, Newyorkable

  mount_uploader :preview, PreviewUploader

  before_create :populate_letters, unless: :skip_callbacks
  after_create :populate_cells, unless: :skip_callbacks

  default_scope -> { order(created_at: :desc) }
  scope :unowned, -> (user) { where.not(user_id: user.id)} # DEBUG only

  # Searchable by title using pg_search gem
  include PgSearch::Model
  pg_search_scope :starts_with,
    against: :title,
  using: {
    tsearch:  {prefix: true}
  }

  has_many :comments, -> {order(created_at: :desc) }, inverse_of: :crossword, dependent: :destroy
  has_many :solutions, inverse_of: :crossword, dependent: :destroy
  has_many :cells, -> { order(:index) }, inverse_of: :crossword, dependent: :destroy
  has_many :across_clues, through: :cells
  has_many :down_clues, through: :cells
  has_many :across_words, through: :across_clues, source: :word
  has_many :down_words, through: :down_clues, source: :word

  has_many :favorite_puzzles, inverse_of: :crossword
  has_many :favoriters, through: :favorite_puzzles, source: :user

  has_many :solution_partnerings, through: :solutions, inverse_of: :crossword

  self.per_page = 100

  #INSTANCE METHODS

  def nonvoid_letter_count
    letters.delete(' _').length
  end

  def is_void_at?(row, col)
    if letters.empty?
      false
    else
      [' ','_'].include? letters[index_from_rc(row,col)-1]
    end
  end

  def string_from_cells
    cells.map(&:formatted_letter).join
  end

  #TODO Keep looking for ways to turn this into a pure scope instead of a function/scope mix?
  def across_start_cells
    cells.across_start_cells
  end

  def down_start_cells
    cells.down_start_cells
  end

  def get_mismatches(solution_letters)
    raise ArgumentError, "Expected #{letters.length} chars, got #{solution_letters.length}" unless solution_letters.length == letters.length
    letters.chars.each_with_index.filter_map { |letter, i| i if letter != solution_letters[i] }
  end

  # Returns { position => incorrect? } for check_cell.js.erb.
  # With indices: spot-checks the given positions (array of ints).
  # Without indices: checks every cell; position is 0-based offset into letters.
  def cell_mismatches(letters_param, indices: nil)
    if indices
      letters_param.each_with_index.to_h do |v, i|
        pos = indices[i]
        [pos, v != letters[pos]]
      end
    else
      letters_param.split('').each_with_index.to_h do |v, i|
        [i, (v != ' ') && (v != '_') && (v != letters[i])]
      end
    end
  end

  # The transaction in this method does not seem to help. Maaaybe 1% speed improvement.
  def number_cells
    #Again...make this work for NYT
    # error_if_published
    counter = 1
    #order by index
    cells.each do |cell|
      cell.update_starts!
    end
    Cell.transaction do
      cells.each do |cell|
        if cell.should_be_numbered?
          cell.cell_num = counter
          counter += 1
        else
          cell.cell_num = nil
        end
        if cell.changed?
          cell.save
        end
      end
    end
    self
  end

  #populates blank letters
  def populate_letters
    # NEED A WAY TO CHECK THIS THAT DOESN'T AFFECT NYT CROSSWORDS
    # error_if_published 
    if letters.empty?
      self.letters = ' '*(rows * cols)
      self
    else
      raise "This crossword has letters (even if they are blank)"
    end
  end

  # Bulk-inserts all clues and cells for a freshly created crossword.
  # Each cell gets one across clue + one down clue, all pre-filled with placeholder text.
  # See: https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
  def populate_cells
    raise "This crossword already has cells!" unless cells.empty?

    # Insert all clues in one statement and get back their IDs via RETURNING.
    # This is atomic: there is no gap between "read next ID" and "insert", so
    # concurrent crossword creation can't accidentally share clue IDs (the old
    # Clue.next_index approach had that race).
    clue_values = (["('ENTER CLUE')"] * area * 2).join(", ")
    clue_ids = ActiveRecord::Base.connection
                 .execute("INSERT INTO clues (content) VALUES #{clue_values} RETURNING id;")
                 .map { |r| r["id"].to_i }
    # clue_ids order matches insertion order: [across_0, down_0, across_1, down_1, ...]

    cell_inserts = []
    cell_num = 1
    (1..rows).each do |row|
      (1..cols).each do |col|
        idx         = (row - 1) * cols + col
        pair_base   = (idx - 1) * 2          # index into clue_ids for this cell
        across_id   = clue_ids[pair_base]
        down_id     = clue_ids[pair_base + 1]
        numbered    = (row == 1 || col == 1)  # edge cells start a word and get a number
        num_val     = numbered ? cell_num : "NULL"
        cell_num   += 1 if numbered

        cell_inserts << "(#{across_id}, #{down_id}, #{row}, #{col}, #{idx}, false, " \
                        "#{col == 1}, #{row == 1}, #{num_val}, #{id})"
      end
    end

    cells_sql = "INSERT INTO cells " \
                "(across_clue_id, down_clue_id, row, col, index, is_void, " \
                "is_across_start, is_down_start, cell_num, crossword_id) " \
                "VALUES #{cell_inserts.join(', ')}"
    ActiveRecord::Base.connection.execute(cells_sql)
    self
  end

  #TODO get a better name
  def set_contents(letters_string)
    # MAKE THIS WORK FOR NYT PUZZLES
    # error_if_published
    if letters_string.length == area
      #WHY WOULD IT DO THIS TWICE
      # error_if_published
      self.letters = letters_string
      if save
        update_cells_from_letters
      else
        raise 'Save failed!'
      end
    else
      raise ArgumentError
    end
  end

  def set_clue(across, cell_num, content)
    #Make this work for NYT
    # error_if_published
    cell = cells.find_by_cell_num(cell_num)
    if cell
      clue = across ? cell.across_clue : cell.down_clue
      if clue
        clue.content = content
        clue.save
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def build_seed(pseudonym)
    output = "\n#Generated seed for \"#{title}\" crossword\n"
    #Basic
    output += "#{pseudonym} = Crossword.create(title: '#{title}', description: '#{description}', rows: #{rows}, cols: #{cols})\n"
    #Letters
    output += "#{pseudonym}.set_letters('#{letters}')\n\n"
    output += "#Across clues for #{pseudonym}\n"
    #Clues
    across_start_cells.each do |cell|
      output += "#{pseudonym}.set_clue(true, #{cell.cell_num}, '#{cell.across_clue.content.gsub("\\","\\\\\\\\").gsub("'","\\\\'")}')\n"
    end
    output += "\n#Down clues for #{pseudonym}\n"
    down_start_cells.each do |cell|
      output += "#{pseudonym}.set_clue(true, #{cell.cell_num}, '#{cell.down_clue.content.gsub("\\","\\\\\\\\").gsub("'","\\\\'")}')\n"
    end
    output += "\n"
    puts output
    output
  end

  #Takes an array of 0s and 1s. A 1 indicates there should be a circle at that index
  def circles_from_array(circle_nums)
    if circle_nums.length == area
      #make an array of the indices that are non-zero
      indices = circle_nums.each_with_index.select{|e, i| e != 0}.map{|e,i| i+1}

      need_circles = cells.where(index: indices)
      if need_circles.count == indices.length
        need_circles.update_all(circled: true)
        update(circled: true)
      else
        raise(ActiveRecord::RecordNotFound, 'Not all cells that needed circles were found.')
      end
    else
      raise "Circles length (#{circle_nums.length}) did not match crossword size (#{area})"
    end
  end

  def generate_preview
    cell_dim = 5
    width_cw = cols*cell_dim
    height_cw = rows*cell_dim

    preview = Magick::Image.new(width_cw, height_cw)

    #Make the black drawing pencil
    gc = Magick::Draw.new
    gc.stroke('black')
    gc.stroke_width(1)
    gc.fill_opacity(0)
    gc.fill('black')

    # Draw the Rows and Columns as 1px-width lines
    (1...rows).each do |r|
      gc.line(0, r*5, width_cw, r*5)
    end
    (1...cols).each do |c|
      gc.line(c*5, 0, c*5, height_cw)
    end

    #Fill in void cells with black squares
    cells.each do |cell|
      gc.rectangle(
        (cell.col-1)*cell_dim,
        (cell.row-1)*cell_dim,
        cell.col*cell_dim,
        cell.row*cell_dim
      ) if cell.is_void?
    end

    gc.draw(preview)
    file_name = "tmp/preview_#{id}.png"
    preview.write(file_name)
    self.preview = File.open(file_name)
    save
    File.delete(file_name)
    puts "Generated preview for Crossword \##{id}, \"#{title}\""
  end

  def randomize_letters_and_voids(symmetrical=true, modify_cells=false)
    error_if_published
    self.letters = Faker::Lorem.characters(number: area)
    upper_limit = (symmetrical ? (area/2.0).ceil : area)
    (1..upper_limit).each do |i|
      if (rand * 10) > 7
        letters[i-1] = '_'
        if symmetrical && ((i.even?) || (i != upper_limit))
          letters[area-i] = '_'
        end
        if modify_cells
          cell = cells.find_by_index(i)
          cell.is_void!
          if symmetrical
            cell.get_mirror_cell.is_void!
          end
        end
      end
    end
    if modify_cells
      letters.split('').each_with_index do |letter, i|
        unless letter =~ / _/
          cell = cells.find_by_index(i+1)
          cell.letter = letter
          cell.save
        end
      end
    end
    self
  end

  def to_s(highlight_index=nil, spoil=true, blocks=true)
    letters_a = letters.split('')
    output = ''
    index = 1
    until letters_a.empty?
      letter = letters_a.shift
      if !spoil && letter != '_'
        letter = '?'
      end
      if highlight_index && (index == highlight_index)
        letter = Rainbow(letter).green
      end
      output += letter
      if (index % cols == 0)
        output += "\n"
      else
        output += ' '
      end
      index += 1
    end
    output
    if blocks
      output.gsub!('_', "\u2588")
      output.gsub('?', "_")

    end
  end

  #Takes an existing crossword puzzle and figures out all of the words in that crossword by cell.
  #Then constructs a hash whose keys are the words and whose values are the clues to those words

  #TODO: This will not work if the same word is used multiple times in a puzzle!!!!
  def get_words_hsh
    word_clues = {}
    cells.across_start_cells.each do |across_start|
      word = ''
      current = across_start
      clue = current.across_clue
      while current && !current.is_void
        word += current.letter
        current = current.right_cell
      end
      word_clues[word] ||= []
      word_clues[word] += [clue]
    end
    cells.down_start_cells.each do |down_start|
      word = ''
      current = down_start
      clue = current.down_clue
      while current && !current.is_void
        word += current.letter
        current = current.below_cell
      end
      word_clues[word] ||= []
      word_clues[word] += [clue]
    end
    word_clues
  end

  def generate_words_and_link_clues
    words_hsh = self.get_words_hsh

    words_hsh.each do |word, clue|
      the_word = Word.find_or_create_by(content: word)
      the_word.clues << clue
    end
  end

  def publish!
    error_if_published
    letters = string_from_cells
    cells.each do |cell|
      cell.delete_extraneous_cells!
    end
    number_cells
    generate_words_and_link_clues
    # published/published_at columns removed from schema; omit from update for now.
    update(letters: letters)
    self
  end

  # CLASS METHODS

  def self.random_row_or_col
    (1..Crossword::MAX_DIMENSION).to_a.sample
  end

  def self.random_dimension(max_reduc=0)
    (Crossword::MIN_DIMENSION..(Crossword::MAX_DIMENSION - max_reduc)).to_a.sample
  end

  def format_for_api(include_comments=false)
    acceptable_keys = [:title, :rows, :cols, :letters, :description, :circled, :published_at, :created_at]
    hash = attributes.symbolize_keys.delete_if{|k,v| !k.in? acceptable_keys}
    hash[:creator] = user.username
    if include_comments && !(include_comments.downcase.in?(['false', 'f', '0']))
      hash[:comment_count] = comments.count
      hash[:comments] = comments.map{|c| c.format_for_api}
    end
    hash
  end


  private
  def error_if_published
    # published column was removed from schema; this guard is currently a no-op.
    # Re-enable once the column is restored.
  end

  #Using a transaction cut down call times by 1.5x to 3.3x for this method
  def update_cells_from_letters
    Cell.transaction do
      cells.each_with_index do |cell, i|
        changed = false
        letter = letters[i]

        if [' ', '_'].include? letter
          if !cell.is_void?
            cell.is_void!
            changed = true
          end
        else
          if cell.letter != letter
            cell.letter = letter
            cell.is_not_void!
            changed = true
          end
        end
        if changed
          cell.save
        end
      end
    end
    self
  end

end
