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
  # Currently clues are populated using raw SQL. While dangerous, it works.
  # after_create :populate_clues

  scope :across_start_cells, -> {where(is_across_start: true)}
  scope :down_start_cells, -> { where(is_down_start: true)}
  scope :asc_indices, -> {order(index: :asc)}
  scope :desc_indices, -> {order(index: :desc)}
  scope :published, -> {where(published: true)}
  scope :unpublished, -> {where(published: false)}
  scope :circled, -> {where(circled: true)}
  scope :uncircled, -> {where(circled: true)}

  belongs_to :across_clue, class_name: 'Clue', foreign_key: 'across_clue_id', inverse_of: :across_cells, optional: true
  belongs_to :down_clue, class_name: 'Clue', foreign_key: 'down_clue_id', inverse_of: :down_cells, optional: true
  belongs_to :crossword, inverse_of: :cells, optional: true

  has_one :cell_edit, inverse_of: :cell, dependent: :destroy #TODO decide whether to use cell_edits or maintain within the cell model

  #A Cell belongs to the user that created its crossword, and can have, at most, one down word and one across word that starts in its cell
  delegate :across_word, to: :across_clue, allow_nil: true
  delegate :down_word, to: :down_clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true
  delegate :published, to: :crossword

  #do not include is_void and other booleans in this validation -- false counts as blank
  validates_presence_of :row, :col, :index
  
  validates :row, numericality: {only_integer: true}, inclusion: {in: 1..Crossword::MAX_DIMENSION}
  validates :col, numericality: {only_integer: true}, inclusion: {in: 1..Crossword::MAX_DIMENSION}

  # Currently clues are populated using raw SQL. While dangerous, it works.
  # def populate_clues
  #   self.across_clue = Clue.create!(content: 'ENTER CLUE')
  #   self.down_clue = Clue.create!(content: 'ENTER CLUE')
  #   self.save
  # end

  def clues
    [across_clue, down_clue]
  end

  def to_s
    "#{self.id}. Cell at [#{self.row}, #{self.col}], #{self.index.ordinalize} cell in Crossword #{self.crossword.id}#{" with cell number #{self.cell_num}" if self.cell_num}. #{"Is across start. " if self.is_across_start}#{"Is down start. " if self.is_down_start}"
  end

  #TODO find a better name for this method
  def formatted_letter
    is_void ? '_' : letter
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

  def left_cell
    unless col == 1
      crossword.cells.find_by_row_and_col(row, col-1)
    end
  end

  def right_cell
    unless col == crossword.cols
      crossword.cells.find_by_row_and_col(row, col+1)
    end
  end

  def above_cell
    unless row == 1
      crossword.cells.find_by_row_and_col(row-1, col)
    end
  end

  def below_cell
    unless row == crossword.rows
      crossword.cells.find_by_row_and_col(row+1, col)
    end
  end

  def get_mirror_cell
    opposing_row = crossword.rows-row+1
    opposing_col = crossword.cols-col+1
    Cell.find_by_row_and_col_and_crossword_id(opposing_row, opposing_col, crossword.id)
  end

  def delete_extraneous_cells!
      self.update_starts!
      self.across_clue.destroy if ((self.is_void? || !self.is_across_start) and self.across_clue)
      self.down_clue.destroy if ((self.is_void? || !self.is_down_start) and self.down_clue)
  end

  def is_void!
    unless self.is_void
      if self.update_attribute(:is_void, true)
        self.letter = nil
        self.update_starts!
        self.right_cell.update_starts! if self.right_cell
        self.below_cell.update_starts! if self.below_cell
      end
    end
  end

  def is_not_void!
    if self.is_void
      if self.update_attribute(:is_void, false)
        self.update_starts!
        self.right_cell.update_starts! if self.right_cell
        self.below_cell.update_starts! if self.below_cell
      end
    end
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
