# == Schema Information
#
# Table name: crosswords
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("Untitled"), not null
#  letters        :text             default(""), not null
#  description    :text
#  rows           :integer          default(15), not null
#  cols           :integer          default(15), not null
#  published      :boolean          default(FALSE), not null
#  date_published :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Crossword < ActiveRecord::Base
  attr_accessible :title, :published, :date_published, :description, :rows, :cols, :letters, :user_id, :comment_ids, :solution_ids, :clue_ids

  before_create :populate_letters, :populate_cells
  # after_create :link_cells

  scope :published, -> {where(published: true)}
  scope :unpublished, -> {where(published: false)}
  scope :unowned, lambda{ |user| where('user_id != ?', user.id)}

  # Searchable by title using pg_search gem
  include PgSearch
  pg_search_scope :starts_with,
    against: :title,
    using: {
      tsearch:  {prefix: true}
    }

  belongs_to :user, inverse_of: :crosswords
  has_many :comments, inverse_of: :crossword, dependent: :delete_all
  has_many :solutions, inverse_of: :crossword, dependent: :delete_all
  has_many :cells, inverse_of: :crossword, dependent: :delete_all
  has_and_belongs_to_many :words

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

  def rc_to_index(row, col)
    (row-1)*(self.cols)+(col-1)
  end

  def index_to_row(index)
    (index / self.cols) + 1
  end

  def index_to_col(index)
    (index % self.rows) + 1
  end

  def index_to_rc(index)
    row = (index / self.cols) + 1
    col = (index % self.rows) + 1
    [row, col]
  end

  def letters_a
    self.letters.split('')
  end

  def is_void_at?(row, col)
    self.letters.present? ? ([' ','_'].include? self.letters[self.rc_to_index(row,col)]) : nil
  end

  def publish!
    if self.update_attribute(:published, true)
    #remove extraneous clues
      self.cells.each do |cell|
        cell.delete_extraneous_cells!
      end
      true
    else
      false
    end
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
    self.cells.each do |cell|
      cell.update_starts!
    end
    self.cells.order('index ASC').each do |cell|
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
    self.letters = ' '*(self.rows*self.cols)
  end

  def populate_cells
    index = 1
    cell_num = 1
    row = 1
    while row <= self.rows
      col = 1
      while col <= self.cols
        if (row == 1 || col == 1)
          temp_cell = Cell.new(row: row, col: col, index: index, is_void: false, is_across_start: col == 1, is_down_start: row == 1, cell_num: cell_num)
          cell_num += 1
        else
          temp_cell = Cell.new(row: row, col: col, index: index, is_void: false, is_across_start: col == 1, is_down_start: row == 1)
        end
        self.cells << temp_cell
        # p "Populating (#{row},#{col}) with a across: #{temp_cell.is_across_start} , down: #{temp_cell.is_down_start} cell"
        index += 1
        col += 1
      end
      row += 1
    end
    # p self.cells
  end

  def link_cells
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

  def across_clues
    Clue.joins('INNER JOIN cells ON cells.across_clue_id = clues.id').where('cells.crossword_id = ?', self.id).order('cells.index ASC')
  end
  def down_clues
    Clue.joins('INNER JOIN cells ON cells.down_clue_id = clues.id').where('cells.crossword_id = ?', self.id).order('cells.index ASC')
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

  #INSTANCE METHODS
  def self.add_latest_nyt
    latest = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx")
    latest_letters = latest['grid'].join('').gsub('.','_')

    new_nytimes_crossword = Crossword.create(
                                                    title: latest['title'],
                                                    rows: latest['size']['rows'],
                                                    cols: latest['size']['cols']
                                                    )

    new_nytimes_crossword.link_cells
    new_nytimes_crossword.letters = latest_letters
    new_nytimes_crossword.set_letters(latest_letters)
    new_nytimes_crossword.number_cells

    nytimes = User.find_by_username('nytimes')

    nytimes.crosswords << new_nytimes_crossword

    #adds the clues
    across_clues = latest['clues']['across']
    down_clues = latest['clues']['down']

    across_clues.each do |across_clue|
      split_clue = across_clue.split('. ', 2)
      new_nytimes_crossword.set_clue(true, split_clue[0].to_i, split_clue[1])
    end

    down_clues.each do |down_clue|
      split_clue = down_clue.split('. ', 2)
      new_nytimes_crossword.set_clue(false, split_clue[0].to_i, split_clue[1])
    end

    puts latest_letters
    puts new_nytimes_crossword.letters
  end

end
