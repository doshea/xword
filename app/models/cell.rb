# == Schema Information
#
# Table name: cells
#
#  id              :integer          not null, primary key
#  row             :integer          not null
#  col             :integer          not null
#  index           :integer          not null
#  is_void         :boolean          default(FALSE), not null
#  across_clue_id  :integer
#  down_clue_id    :integer
#  crossword_id    :integer
#  is_across_start :boolean          default(FALSE), not null
#  is_down_start   :boolean          default(FALSE), not null
#  left_cell_id    :integer
#  right_cell_id   :integer
#  above_cell_id   :integer
#  below_cell_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Cell < ActiveRecord::Base
  attr_accessible :row, :col, :index, :is_void, :across_clue_id, :down_clue_id, :crossword_id, :is_across_start, :is_down_start

  belongs_to :across_clue, polymorphic: true, inverse_of: :cells
  belongs_to :down_clue, polymorphic: true, inverse_of: :cells
  belongs_to :crossword, inverse_of: :cells

  has_one :left_cell, class_name: "Cell", foreign_key: "left_cell_id"
  has_one :right_cell, class_name: "Cell", foreign_key: "right_cell_id"
  has_one :above_cell, class_name: "Cell", foreign_key: "above_cell_id"
  has_one :below_cell, class_name: "Cell", foreign_key: "below_cell_id"

  delegate :word, to: :clue, allow_nil: true
  delegate :user, to: :crossword, allow_nil: true

  def to_s
    "#{self.id}. Cell at [#{self.row}, #{self.col}], #{self.index.ordinalize} cell in Crossword #{self.crossword.id}. #{"Is across start. " if self.is_across_start}#{"Is down start. " if self.is_down_start}"
  end

  def is_across_start?
    self.left_cell.present? ? self.left_cell.is_void : true
    # (self.col == 1) || (self.crossword.cells.where("row = ? AND col = ?", self.row, self.col - 1).first.is_void)
  end

  def is_across_start!
    self.is_across_start = self.is_across_start?
    self.save
  end

  def is_down_start?
    self.above_cell.present? ? self.above_cell.is_void : true
    # (self.row == 1) || (self.crossword.cells.where("row = ? AND col = ?", self.row-1, self.col).first.is_void)
  end

  def is_down_start!
    self.is_down_start = self.is_down_start?
    self.save
  end

  def assign_bordering_cells!
    self.left_cell = self.crossword.cells.find_by_row_and_col(self.row, self.col-1) unless (self.col == 1)
    self.right_cell = self.crossword.cells.find_by_row_and_col(self.row, self.col+1) unless (self.col == self.crossword.cols)
    self.above_cell = self.crossword.cells.find_by_row_and_col(self.row-1, self.col) unless (self.row == 1)
    self.below_cell = self.crossword.cells.find_by_row_and_col(self.row+1, self.col) unless (self.row == self.crossword.rows)

  end

end
