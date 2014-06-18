# == Schema Information
#
# Table name: crosswords
#
#  id           :integer          not null, primary key
#  title        :string(255)      default("Untitled"), not null
#  letters      :text             default(""), not null
#  description  :text
#  rows         :integer          default(15), not null
#  cols         :integer          default(15), not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  user_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#  circled      :boolean          default(FALSE)
#  preview      :text
#

class Crossword < ActiveRecord::Base
  include Publishable, Newyorkable
  attr_accessible :title, :description, :rows, :cols, :letters, :user_id, :comment_ids, :solution_ids, :clue_ids, :circled, :preview

  mount_uploader :preview, PreviewUploader

  before_create :populate_letters, unless: :skip_callbacks
  after_create :populate_cells, unless: :skip_callbacks

  scope :unowned, -> (user) { where.not(user_id: user.id)}

  # Searchable by title using pg_search gem
  include PgSearch
  pg_search_scope :starts_with,
    against: :title,
  using: {
    tsearch:  {prefix: true}
  }

  belongs_to :user, inverse_of: :crosswords
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

  has_and_belongs_to_many :potential_words, class_name: 'Word', join_table: :potential_crosswords_potential_words

  self.per_page = 12

  # A crossword must be between 4x4 and 30x30 and its title must be 3-35 characters long
  MIN_DIMENSION = 4
  MAX_DIMENSION = 30

  validates :rows,
    presence: true,
    numericality: { only_integer: true },
    inclusion: {in: MIN_DIMENSION..MAX_DIMENSION}

  validates :cols,
    presence: true,
    numericality: { only_integer: true },
    inclusion: {in: MIN_DIMENSION..MAX_DIMENSION}

  MIN_TITLE_LENGTH = 3
  MAX_TITLE_LENGTH = 35

  validates :title,
    presence: true,
    length: { minimum: MIN_TITLE_LENGTH, maximum: MAX_TITLE_LENGTH}

  #INSTANCE METHODS
  def random_row
    (1..rows).to_a.sample
  end

  def random_col
    (1..cols).to_a.sample
  end

  def random_index
    index_from_rc(random_row, random_col)
  end

  def index_from_rc(row, col)
    if (row.in? (1..rows)) && (col.in? (1..cols))
      (row-1) * cols + col
    else
      raise ArgumentError, "(#{row}x#{col}) are outside the Crossword's dimensions (#{rows}x#{cols})."
    end
  end

  def row_from_index(index)
    if index.in? (1..area)
      (index / cols.to_f).ceil
    else
      raise ArgumentError, "Index (#{index}) out of bounds (1-#{area})."
    end
  end

  def col_from_index(index)
    if index.in? (1..area)
      (index % cols == 0) ? cols : (index % cols)
    else
      raise ArgumentError, "Index (#{index}) out of bounds (1-#{area})."
    end
  end

  def area
    rows * cols
  end

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
    if solution_letters.length == letters.length
      mismatch_array = []
      letters.split('').each_with_index do |letter, i|
        if letter != solution_letters[i]
          mismatch_array << i
        end
      end
      mismatch_array
    else
      raise ArgumentError, "Argument string (#{solution_letters.length}) did not match solution length(#{letters.length})."
    end
  end

  # The transaction in this method does not seem to help. Maaaybe 1% speed improvement.
  def number_cells
    error_if_published
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
    error_if_published
    if letters.empty?
      self.letters = ' '*(rows * cols)
      self
    else
      raise "This crossword has letters (even if they are blank)"
    end
  end

  #Refactored to use a single SQL statement and run at light speed
  #Read https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
  def populate_cells
    error_if_published
    if cells.empty?
      row = cell_num = index = 1

      #make clues_first
      clue_inserts = ["('ENTER CLUE')"]*area*2
      clues_sql = "INSERT INTO clues (content) VALUES #{clue_inserts.join(", ")}"

      next_clue_id = Clue.next_index #TODO This may cause a race condition!!!
      ActiveRecord::Base.connection.execute(clues_sql)

      cell_inserts = []
      while row <= rows
        col = 1
        while col <= cols
          # temp_cell = Cell.new(row: row, col: col, index: index, is_void: false, is_across_start: col == 1, is_down_start: row == 1)
          # if (row == 1 or col == 1)
          #   temp_cell.cell_num = cell_num
          #   cell_num += 1
          # end
          # cells << temp_cell
          temp_insert = "(#{next_clue_id}, #{next_clue_id+1},#{row}, #{col}, #{index}, #{false}, #{col == 1}, #{row == 1}, #{(row == 1 || col == 1) ? cell_num : 'NULL'}, #{id || Crossword.next_index || 1})"
          if (row == 1 || col == 1)
            cell_num += 1
          end
          cell_inserts.push(temp_insert)

          index += 1
          col += 1
          next_clue_id += 2
        end
        row += 1
      end
      cells_sql = "INSERT INTO cells (across_clue_id, down_clue_id, row, col, index, is_void, is_across_start, is_down_start, cell_num, crossword_id) VALUES #{cell_inserts.join(", ")}"
      ActiveRecord::Base.connection.execute(cells_sql)
      self
    else
      raise "This crossword already has cells!"
    end
  end

  #TODO get a better name
  def set_contents(letters_string)
    error_if_published
    if letters_string.length == area
      error_if_published
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
    error_if_published
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
        update_attributes(circled: true)
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
    self.letters = Faker::Lorem.characters(area)
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

  def to_s(highlight_index=nil)
    letters_a = letters.split('')
    index = 1
    until letters_a.empty?
      if highlight_index && index == highlight_index
        print Rainbow(letters_a.shift).green
      else
        print letters_a.shift
      end
      if (index % cols == 0)
        puts
      else
        print ' '
      end
      index += 1
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
    letters = self.string_from_cells
    if self.update_attributes(published: true, published_at: Time.now, letters: letters)
      #remove extraneous clues
      self.cells.each do |cell|
        cell.delete_extraneous_cells!
      end
      self.number_cells
      self.generate_words_and_link_clues
    else
      raise 'Updating attributes failed -- task aborted!'
    end
  end

  # CLASS METHODS

  def self.random_row_or_col
    (1..Crossword::MAX_DIMENSION).to_a.sample
  end

  def self.random_dimension(max_reduc=0)
    (Crossword::MIN_DIMENSION..(Crossword::MAX_DIMENSION - max_reduc)).to_a.sample
  end


  private
  def error_if_published
    if published
      raise 'Published crosswords cannot perform that action.'
    end
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
