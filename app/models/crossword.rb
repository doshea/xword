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
  include Crosswordable, Publishable

  mount_uploader :preview, PreviewUploader

  before_create :populate_letters, unless: :skip_callbacks
  after_create :populate_cells, unless: :skip_callbacks

  scope :unowned, -> (user) { where.not(user_id: user.id)}

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

  has_many :favorite_puzzles, inverse_of: :crossword, dependent: :destroy
  has_many :favoriters, through: :favorite_puzzles, source: :user

  has_many :solution_partnerings, through: :solutions, inverse_of: :crossword

  self.per_page = 30

  # Spaces = unfilled cells, underscores = voids. Count only letter-bearing cells.
  def nonvoid_letter_count
    letters.delete(' _').length
  end

  def rebus?
    rebus_map.present?
  end

  # Full answer at 0-based cell index. Multi-char for rebus, single char otherwise.
  def answer_at(i)
    rebus_map[i.to_s] || letters[i]
  end

  def is_void_at?(row, col)
    if letters.empty?
      false
    else
      # index_from_rc is 1-based; string indexing is 0-based
      [' ','_'].include? letters[index_from_rc(row,col)-1]
    end
  end

  def string_from_cells
    cells.map(&:formatted_letter).join
  end

  def across_start_cells
    cells.across_start_cells
  end

  def down_start_cells
    cells.down_start_cells
  end

  def get_mismatches(solution_letters, rebus_answers: {})
    raise ArgumentError, "Expected #{letters.length} chars, got #{solution_letters.length}" unless solution_letters.length == letters.length
    if rebus? && rebus_answers.any?
      (0...letters.length).filter_map do |i|
        expected = answer_at(i)
        actual = expected.length > 1 ? (rebus_answers[i.to_s] || solution_letters[i]) : solution_letters[i]
        i if actual != expected
      end
    else
      letters.chars.each_with_index.filter_map { |letter, i| i if letter != solution_letters[i] }
    end
  end

  # Returns { position => incorrect? } for check_cell.js.erb.
  # With indices: spot-checks the given positions (array of ints).
  # Without indices: checks every cell; position is 0-based offset into letters.
  def cell_mismatches(letters_param, indices: nil, rebus_answers: {})
    if indices
      letters_param.each_with_index.filter_map do |v, i|
        pos = indices[i]
        next if pos.nil? || pos < 0 || pos >= letters.length
        [pos, v != answer_at(pos)]
      end.to_h
    else
      letters_param.split('').each_with_index.to_h do |v, i|
        if rebus_answers.key?(i.to_s)
          [i, rebus_answers[i.to_s] != answer_at(i)]
        elsif rebus_map.key?(i.to_s) && v != ' ' && v != '_'
          # User typed something but didn't provide full rebus answer — incorrect
          [i, true]
        else
          [i, (v != ' ') && (v != '_') && (v != letters[i])]
        end
      end
    end
  end

  # Transaction ensures cells are numbered atomically.
  def number_cells
    counter = 1
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
    if letters.empty?
      self.letters = ' '*(rows * cols)
      self
    else
      raise "This crossword has letters (even if they are blank)"
    end
  end

  # Bulk-inserts all clues and cells for a freshly created crossword.
  # Each cell gets one across clue + one down clue, all pre-filled with placeholder text.
  def populate_cells
    raise "This crossword already has cells!" unless cells.empty?

    # Atomic bulk insert via RETURNING to avoid ID race conditions.
    clue_values = (["('#{Clue::DEFAULT_CONTENT}')"] * area * 2).join(", ")
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
    cells.reset   # Clear ActiveRecord cache so subsequent queries see the raw-SQL-inserted rows
    self
  end

  def set_contents(letters_string, new_rebus_map: nil)
    if letters_string.length == area
      self.letters = letters_string
      self.rebus_map = new_rebus_map if new_rebus_map
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
      output += "#{pseudonym}.set_clue(false, #{cell.cell_num}, '#{cell.down_clue.content.gsub("\\","\\\\\\\\").gsub("'","\\\\'")}')\n"
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
            mirror = cell.get_mirror_cell
            mirror.is_void! if mirror
          end
        end
      end
    end
    if modify_cells
      letters.split('').each_with_index do |letter, i|
        unless letter =~ /[ _]/
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
    if blocks
      output.gsub!('_', "\u2588")
      output.gsub!('?', "_")
    end
    output
  end

  # Builds { word_string => [clue, ...] } for all across and down words.
  # NOTE: duplicate words in a puzzle will merge their clues into one key.
  def get_words_hsh
    word_clues = {}
    collect_direction_words(word_clues, cells.across_start_cells, :across_clue, :right_cell)
    collect_direction_words(word_clues, cells.down_start_cells, :down_clue, :below_cell)
    word_clues
  end

  def generate_words_and_link_clues
    words_hsh = self.get_words_hsh

    # Batch-load existing words and phrases to avoid N+1 queries
    word_strings = words_hsh.keys
    existing_words = Word.where(content: word_strings).index_by(&:content)

    clue_texts = words_hsh.values.flatten
      .select { |c| c.content.present? && c.content != Clue::DEFAULT_CONTENT }
      .map { |c| c.content.strip.downcase }.uniq
    existing_phrases = Phrase.where("LOWER(content) IN (?)", clue_texts)
      .index_by { |p| p.content.strip.downcase } if clue_texts.any?
    existing_phrases ||= {}

    words_hsh.each do |word, clues|
      the_word = existing_words[word] ||= begin
        Word.find_or_create_by(content: word)
      rescue ActiveRecord::RecordNotUnique
        Word.find_by!(content: word)
      end

      clues.each do |clue|
        attrs = { word: the_word }
        if clue.content.present? && clue.content != Clue::DEFAULT_CONTENT
          key = clue.content.strip.downcase
          attrs[:phrase] = existing_phrases[key] ||= Phrase.find_or_create_by_content(clue.content)
        end
        clue.update!(attrs)
      end
    end
  end

  def self.random_row_or_col
    (1..Crossword::MAX_DIMENSION).to_a.sample
  end

  def self.random_dimension(max_reduc=0)
    (Crossword::MIN_DIMENSION..(Crossword::MAX_DIMENSION - max_reduc)).to_a.sample
  end

  private

  def collect_direction_words(word_clues, start_cells, clue_method, next_method)
    start_cells.each do |start_cell|
      word = ''
      current = start_cell
      clue = current.send(clue_method)
      while current && !current.is_void
        word += current.letter
        current = current.send(next_method)
      end
      word_clues[word] ||= []
      word_clues[word] += [clue]
    end
  end

  # Transaction batches cell saves to reduce DB round-trips.
  def update_cells_from_letters
    Cell.transaction do
      cells.each_with_index do |cell, i|
        changed = false
        letter = letters[i]
        full_answer = answer_at(i)

        if [' ', '_'].include? letter
          if !cell.is_void?
            cell.is_void!
            changed = true
          end
        else
          if cell.letter != full_answer
            cell.letter = full_answer
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
