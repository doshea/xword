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
#  letters        :text
#  gridnums       :text
#  circles        :text
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Crossword < ActiveRecord::Base
  attr_accessible :title, :published, :date_published, :description, :rows, :cols, :letters, :gridnums, :circles, :user_id, :comment_ids, :solution_ids, :clue_instance_ids, :clue_ids

  include PgSearch
  pg_search_scope :starts_with,
                  :against => :title,
                  :using => {
                    :tsearch => {:prefix => true}
                  }

  serialize :letters, Array
  serialize :gridnums, Array
  serialize :circles, Array

  belongs_to :user, :inverse_of => :crosswords
  has_many :comments, :inverse_of => :crossword
  has_many :solutions, :inverse_of => :crossword
  has_many :clue_instances, :inverse_of => :crossword
  has_many :clues, :through => :clue_instances, :inverse_of => :crosswords
  has_and_belongs_to_many :words

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

  def is_void?(row, col)
    self.letters[rc_to_index(row,col)] == '_'
  end


end
