# == Schema Information
#
# Table name: crosswords
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("Untitled"), not null
#  published      :boolean          default(FALSE)
#  date_published :datetime
#  description    :text
#  rows           :integer          default(15), not null
#  cols           :integer          default(15), not null
#  letters        :text             default(""), not null
#  gridnums       :text             default(""), not null
#  circles        :text
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Crossword < ActiveRecord::Base
  attr_accessible :title, :published, :date_published, :description, :rows, :cols, :letters, :gridnums, :circles, :user_id, :comment_ids, :solution_ids, :clue_instance_ids, :clue_ids

  scope :published, where(published: true)
  scope :unpublished, where(published: false)

  include PgSearch
  pg_search_scope :starts_with,
    against: :title,
    using: {
      tsearch:  {:prefix => true}
    }

  belongs_to :user, :inverse_of => :crosswords
  has_many :comments, :inverse_of => :crossword, :dependent => :delete_all
  has_many :solutions, :inverse_of => :crossword, :dependent => :delete_all
  has_many :clue_instances, :inverse_of => :crossword, :dependent => :delete_all
  has_many :clues, :through => :clue_instances, :inverse_of => :crosswords
  has_and_belongs_to_many :words

  MIN_DIMENSION = 4
  MAX_DIMENSION = 30

  validates :rows,
    :presence => true,
    :numericality => { :only_integer => true , :message => ': Must be an integer'},
    :inclusion => {:in => MIN_DIMENSION..MAX_DIMENSION, :message => ": Dimensions must be #{MIN_DIMENSION}-#{MAX_DIMENSION} in length"}

  validates :cols,
    :presence => true,
    :numericality => { :only_integer => true , :message => ': Must be an integer'},
    :inclusion => {:in => MIN_DIMENSION..MAX_DIMENSION, :message => ": Dimensions must be #{MIN_DIMENSION}-#{MAX_DIMENSION} in length"}

  MIN_TITLE_LENGTH = 3
  MAX_TITLE_LENGTH = 35

  validates :title,
    :presence => true,
    :length => { :minimum => MIN_TITLE_LENGTH, :maximum => MAX_TITLE_LENGTH, :message => ": Must be #{MIN_TITLE_LENGTH}-#{MAX_TITLE_LENGTH} characters long"}

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

  def is_void?(row, col)
    self.letters.present? ? self.letters[rc_to_index(row,col)] == '_' : nil
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

end
