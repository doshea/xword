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

  before_create :populate_letters, :populate_cells, unless: :skip_callbacks
  # after_create :link_cells_to_neighbors

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
    numericality: { only_integer: true , message: ': Must be an integer'},
    inclusion: {in: MIN_DIMENSION..MAX_DIMENSION, message: ": Dimensions must be #{MIN_DIMENSION}-#{MAX_DIMENSION} in length"}

    validates :cols,
    presence: true,
    numericality: { only_integer: true , message: ': Must be an integer'},
    inclusion: {in: MIN_DIMENSION..MAX_DIMENSION, message: ": Dimensions must be #{MIN_DIMENSION}-#{MAX_DIMENSION} in length"}

    MIN_TITLE_LENGTH = 3
  MAX_TITLE_LENGTH = 35

  validates :title,
    presence: true,
    length: { minimum: MIN_TITLE_LENGTH, maximum: MAX_TITLE_LENGTH, message: ": Must be #{MIN_TITLE_LENGTH}-#{MAX_TITLE_LENGTH} characters long"}

  #INSTANCE METHODS
  def random_row
    (0..rows).to_a.sample
  end

  def random_col
    (0..cols).to_a.sample
  end

  def rc_to_index(row, col)
    (row-1)*(self.cols)+(col-1)
  end
  
  def index_to_row(index)
    (index / self.cols) + 1
  end

  def index_to_col(index)
    (index % self.rows) + 1
  end

  def area
    rows * cols
  end

  def nonvoid_letter_count
    self.letters.gsub(/ |_/, '').length
  end

  def is_void_at?(row, col)
    self.letters.present? ? ([' ','_'].include? self.letters[self.rc_to_index(row,col)]) : false
  end

  def check_solution(solution_letters)
    self.letters == solution_letters
  end

  def return_mismatches(solution_letters)
    counter = 1
    mismatch_array = []
    self.letters.split('').each do |letter|
      mismatch_array << counter if letter != solution_letters[counter-1]
      counter += 1
    end
    mismatch_array
  end

  # This can be made more efficient by only updating if the values are different
  def number_cells
    counter = 1
    #order by index
    cells.each do |cell|
      cell.update_starts!
    end
    cells.order('index ASC').each do |cell|
      if cell.should_be_numbered?
        cell.cell_num = counter
        counter += 1
      else
        cell.cell_num = nil
      end
      cell.save
    end

  end

  #populates blank letters
  def populate_letters
    if letters.blank?
      self.letters = ' '*(rows * cols)
    else
      raise "This crossword's letters are not blank!"
    end
  end

  def populate_cells
    if cells.empty?
      index = 1
      cell_num = 1
      row = 1
      while row <= self.rows
        col = 1
        while col <= self.cols
          temp_cell = Cell.new(row: row, col: col, index: index, is_void: false, is_across_start: col == 1, is_down_start: row == 1)
          if (row == 1 or col == 1)
            temp_cell.cell_num = cell_num
            cell_num += 1
          end
          self.cells << temp_cell
          # p "Populating (#{row},#{col}) with a across: #{temp_cell.is_across_start} , down: #{temp_cell.is_down_start} cell"
          index += 1
          col += 1
        end
        row += 1
      end
    else
      raise "This crossword already has cells!"
    end
  end

  def link_cells_to_neighbors
    counter = 1
    self.reload.cells.each do |cell|
      # puts counter
      cell.assign_bordering_cells!
      counter += 1
    end
    # if self.reload.published
    #   self.number_cells
    #   self.publish!
    # end
  end

  def across_start_cells
    self.cells.across_start_cells
  end

  def down_start_cells
    self.cells.down_start_cells
  end

  def set_letters(letter_string)
    if letter_string.length == (self.rows * self.cols) &&  letter_string.length == self.cells.count
      self.cells.asc_indices.each_with_index do |cell, index|
        letter = letter_string[index]
        unless [' ', '_'].include? letter
          cell.letter = letter
          cell.is_not_void!
        else
          cell.is_void!
        end
        cell.save
      end
    else
      raise "String length does not equal dimensions or cell count"
    end
  end

  def update_letters
    output = ''
    self.cells.asc_indices.each do |cell|
      output += cell.letter ? cell.letter : '_'
    end
    self.letters = output
    self.save
  end

  def set_clue(across, cell_num, content)
    cell = self.cells.find_by_cell_num(cell_num)
    clue = across ? cell.across_clue : cell.down_clue
    clue.update_attribute(:content, content)
  end

  def build_seed(pseudonym)
    output = "\n#Generated seed for \"#{self.title}\" crossword\n"
    #Basic
    output += "#{pseudonym} = Crossword.create(title: '#{self.title}', description: '#{self.description}', rows: #{self.rows}, cols: #{self.cols})\n"
    #Letters
    output += "#{pseudonym}.set_letters('#{self.letters}')\n\n"
    output += "#Across clues for #{pseudonym}\n"
    #Clues
    self.across_start_cells.asc_indices.each do |cell|
      output += "#{pseudonym}.set_clue(true, #{cell.cell_num}, '#{cell.across_clue.content.gsub("\\","\\\\\\\\").gsub("'","\\\\'")}')\n"
    end
    output += "\n#Down clues for #{pseudonym}\n"
    self.down_start_cells.asc_indices.each do |cell|
      output += "#{pseudonym}.set_clue(true, #{cell.cell_num}, '#{cell.down_clue.content.gsub("\\","\\\\\\\\").gsub("'","\\\\'")}')\n"
    end
    output += "\n"
    puts output
  end

  def add_circles_by_array(circle_nums)
    if circle_nums.length == self.rows*self.cols
      circle_needers = []
      circle_nums.each_with_index do |potential_circle, index|
        if potential_circle == 1
          id_number = self.cells.find_by_index(index+1).id
          circle_needers << id_number
        end
      end
      Cell.where(id: circle_needers).update_all(circled: true)
      self.update_attributes(circled: true)
    else
      puts "Too many circles"
    end
  end

  def string_from_cells
    self.cells.order(:index).map{|cell| cell.is_void ? '_' : cell.letter }.join
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
    self.cells.each do |cell|
      gc.rectangle(
        (cell.col-1)*cell_dim,
        (cell.row-1)*cell_dim,
        cell.col*cell_dim,
        cell.row*cell_dim
      ) if cell.is_void?
    end

    gc.draw(preview)
    file_name = "tmp/preview_#{self.id}.png"
    preview.write(file_name)
    self.preview = File.open(file_name)
    self.save
    File.delete(file_name)
    puts "Generated preview for Crossword \##{self.id}, \"#{self.title}\""
  end


  # CLASS METHODS

  def self.random_row_or_col
    (1..Crossword::MAX_DIMENSION).to_a.sample
  end

  def self.random_dimension
    (Crossword::MIN_DIMENSION..Crossword::MAX_DIMENSION).to_a.sample
  end
end
