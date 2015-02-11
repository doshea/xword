module Crosswordable
  extend ActiveSupport::Concern

  included do
    #attr_accessible
    #scopes
    #has_many and belongs_to
    belongs_to :user
    validates :rows,
      presence: true,
      numericality: { only_integer: true },
      inclusion: {in: MIN_DIMENSION..MAX_DIMENSION}
    validates :cols,
      presence: true,
      numericality: { only_integer: true },
      inclusion: {in: MIN_DIMENSION..MAX_DIMENSION}
    validates :title,
      presence: true,
      length: { minimum: MIN_TITLE_LENGTH, maximum: MAX_TITLE_LENGTH}
  end

  # A crossword must be between 4x4 and 30x30 and its title must be 3-35 characters long
  MIN_DIMENSION = 4
  MAX_DIMENSION = 30

  MIN_TITLE_LENGTH = 3
  MAX_TITLE_LENGTH = 35

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

  module ClassMethods
    def class_example #notice that there is no "self." in this method name! It is not necessary when using ActiveSupport::Concern!
    end
  end

end