# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  cell_num        :integer
#  is_void         :boolean          default(FALSE), not null
#  is_across_start :boolean          default(FALSE)
#  is_down_start   :boolean          default(FALSE)
#  crossword_id    :integer
#  across_clue_id  :integer
#  down_clue_id    :integer
#  left_cell_id    :integer
#  above_cell_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  letter          :string(255)
#

class Cell < ActiveRecord::Base
  attr_accessible :row, :col, :index, :is_void, :across_clue_id, :down_clue_id, :crossword_id, :is_across_start, :is_down_start, :left_cell_id, :above_cell_id, :cell_num, :letter

  after_create :populate_clues

  scope :across_start_cells, where('is_across_start = ?', true)
  scope :down_start_cells, where('is_down_start = ?', true)
  scope :asc_indices, order('index ASC')
  scope :desc_indices, order('index DESC')

  belongs_to :across_clue, class_name: 'Clue', foreign_key: 'across_clue_id', inverse_of: :across_cells
  belongs_to :down_clue, class_name: 'Clue', foreign_key: 'down_clue_id', inverse_of: :down_cells
  belongs_to :crossword, inverse_of: :cells

  #Sets up two-way associations between cells and their neighbors. Because the relationships are reciprocal, only two fields are required.
  has_one :right_cell, class_name: 'Cell', foreign_key: 'left_cell_id', inverse_of: :left_cell
  has_one :below_cell, class_name: 'Cell', foreign_key: 'above_cell_id', inverse_of: :above_cell
  belongs_to :left_cell, class_name: 'Cell', foreign_key: 'left_cell_id', inverse_of: :right_cell
  belongs_to :above_cell, class_name: 'Cell', foreign_key: 'above_cell_id', inverse_of: :below_cell

  #A Cell belongs to the user that created its crossword, and can have, at most, one down word and one across word that starts in its cell
  delegate :across_word, to: :clue, allow_nil: true
  delegate :down_word, to: :down_clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true

  def populate_clues
    self.across_clue = Clue.create(content: 'ENTER CLUE')
    self.down_clue = Clue.create(content: 'ENTER CLUE')
    self.save
  end

  def to_s
    "#{self.id}. Cell at [#{self.row}, #{self.col}], #{self.index.ordinalize} cell in Crossword #{self.crossword.id}#{" with cell number #{self.cell_num}" if self.cell_num}. #{"Is across start. " if self.is_across_start}#{"Is down start. " if self.is_down_start}"
  end

  def should_be_across_start?
    !self.is_void && (self.left_cell.nil? || self.left_cell.is_void)
    # (self.col == 1) || (self.crossword.cells.where("row = ? AND col = ?", self.row, self.col - 1).first.is_void)
  end

  def should_be_down_start?
    !self.is_void && (self.above_cell.nil? || self.above_cell.is_void)
    # (self.row == 1) || (self.crossword.cells.where("row = ? AND col = ?", self.row-1, self.col).first.is_void)
  end

  def update_starts!
    self.reload #Absolutely NECESSARY otherwise publishing during seeds fails
    original_a_value = self.is_across_start
    original_d_value = self.is_across_start
    self.update_attribute(:is_across_start, self.should_be_across_start?)
    self.update_attribute(:is_down_start, self.should_be_down_start?)
    new_a_value = self.reload.is_across_start
    new_d_value = self.is_down_start
    # puts "Was #{original_a_value} across, now #{new_a_value}. Was #{original_d_value} down, now #{new_d_value}. Should be across: #{self.should_be_across_start?}, down: #{self.should_be_down_start?}. Row: #{self.row}, column: #{self.col} of #{self.crossword.title}"
  end

  def should_be_numbered?
    self.is_across_start || self.is_down_start
  end

  def assign_bordering_cells!
    # self.reload
    # puts "Assign bordering cells for cell in row #{self.row}, column #{self.col}"
    self.left_cell = self.crossword.cells.find_by_row_and_col(self.row, self.col-1) unless (self.col == 1)
    self.above_cell = self.crossword.cells.find_by_row_and_col(self.row-1, self.col) unless (self.row == 1)
    self.save
  end

  def get_mirror_cell
    cw = self.crossword
    opposing_row = cw.rows-self.row+1
    opposing_col = cw.cols-self.col+1
    cw_id = cw.id
    Cell.find_by_row_and_col_and_crossword_id(opposing_row, opposing_col, cw_id)
  end

  def delete_extraneous_cells!
      self.update_starts!
      self.across_clue.destroy if (self.is_void? || !self.is_across_start)
      self.down_clue.destroy if (self.is_void? || !self.is_down_start)
  end

  #
  def toggle_void
    void_status = self.is_void
    if self.update_attribute(:is_void, !void_status)
      self.letter = nil if self.reload.is_void
      self.update_starts!
      self.right_cell.update_starts! if self.right_cell
      self.below_cell.update_starts! if self.below_cell
    end
  end
end
