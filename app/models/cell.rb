# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  letter          :string(255)
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  cell_num        :integer
#  is_void         :boolean          default(FALSE), not null
#  is_across_start :boolean          default(FALSE), not null
#  is_down_start   :boolean          default(FALSE), not null
#  crossword_id    :integer
#  across_clue_id  :integer
#  down_clue_id    :integer
#  circled         :boolean          default(FALSE)
#

class Cell < ApplicationRecord
  scope :across_start_cells, -> {where(is_across_start: true)}
  scope :down_start_cells, -> { where(is_down_start: true)}
  scope :asc_indices, -> {order(index: :asc)}
  scope :desc_indices, -> {order(index: :desc)}
  scope :circled,   -> { where(circled: true) }
  scope :uncircled, -> { where(circled: false) }

  belongs_to :across_clue, class_name: 'Clue', foreign_key: 'across_clue_id', inverse_of: :across_cells, optional: true
  belongs_to :down_clue, class_name: 'Clue', foreign_key: 'down_clue_id', inverse_of: :down_cells, optional: true
  belongs_to :crossword, inverse_of: :cells, optional: true

  delegate :across_word, to: :across_clue, allow_nil: true
  delegate :down_word, to: :down_clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true
  # Exclude booleans from presence validation — false counts as blank.
  validates_presence_of :row, :col, :index
  
  validates :row, numericality: {only_integer: true}, inclusion: {in: 1..Crossword::MAX_DIMENSION}
  validates :col, numericality: {only_integer: true}, inclusion: {in: 1..Crossword::MAX_DIMENSION}

  def clues
    [across_clue, down_clue]
  end

  def to_s
    "#{self.id}. Cell at [#{self.row}, #{self.col}], #{self.index.ordinalize} cell in Crossword #{self.crossword&.id}#{" with cell number #{self.cell_num}" if self.cell_num}. #{"Is across start. " if self.is_across_start}#{"Is down start. " if self.is_down_start}"
  end

  def formatted_letter
    is_void ? '_' : letter
  end

  def should_be_across_start?
    !self.is_void && (self.left_cell.nil? || self.left_cell.is_void)
  end

  def should_be_down_start?
    !self.is_void && (self.above_cell.nil? || self.above_cell.is_void)
  end

  def update_starts!
    self.reload # Required: without reload, in-memory state diverges during bulk seed/publish
    self.update_attribute(:is_across_start, self.should_be_across_start?)
    self.update_attribute(:is_down_start, self.should_be_down_start?)
    self.reload
  end

  def should_be_numbered?
    self.is_across_start || self.is_down_start
  end

  def left_cell  = neighbor_cell(0, -1, col > 1)
  def right_cell = neighbor_cell(0, 1, col < crossword.cols)
  def above_cell = neighbor_cell(-1, 0, row > 1)
  def below_cell = neighbor_cell(1, 0, row < crossword.rows)

  def get_mirror_cell
    opposing_row = crossword.rows-row+1
    opposing_col = crossword.cols-col+1
    Cell.find_by_row_and_col_and_crossword_id(opposing_row, opposing_col, crossword.id)
  end

  # Removes clues that no longer start a word at this cell (e.g., after toggling voids).
  def delete_extraneous_cells!
      self.update_starts!
      self.across_clue.destroy if ((self.is_void? || !self.is_across_start) and self.across_clue)
      self.down_clue.destroy if ((self.is_void? || !self.is_down_start) and self.down_clue)
  end

  def is_void!
    unless self.is_void
      if update_columns(is_void: true, letter: nil)
        self.reload
        refresh_neighbor_starts!
      end
    end
  end

  def is_not_void!
    if self.is_void
      if self.update_attribute(:is_void, false)
        refresh_neighbor_starts!
      end
    end
  end

  def toggle_void
    void_status = self.is_void
    new_attrs = { is_void: !void_status }
    new_attrs[:letter] = nil if !void_status  # becoming void → clear letter
    if update_columns(new_attrs)
      self.reload
      refresh_neighbor_starts!
    end
  end

  private

  def neighbor_cell(row_delta, col_delta, in_bounds)
    crossword.cells.find_by_row_and_col(row + row_delta, col + col_delta) if in_bounds
  end

  def refresh_neighbor_starts!
    self.update_starts!
    self.right_cell.update_starts! if self.right_cell
    self.below_cell.update_starts! if self.below_cell
  end
end
