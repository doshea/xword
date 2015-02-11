# == Schema Information
#
# Table name: unpublished_crosswords
#
#  id              :integer          not null, primary key
#  title           :string           default("Untitled"), not null
#  letters         :text             default("{}"), is an Array
#  description     :text
#  rows            :integer
#  cols            :integer
#  user_id         :integer
#  circles         :text             default("{}"), is an Array
#  potential_words :text             default("{}"), is an Array
#  created_at      :datetime
#  updated_at      :datetime
#  across_clues    :text             default("{}"), is an Array
#  down_clues      :text             default("{}"), is an Array
#

class UnpublishedCrossword < ActiveRecord::Base
  include Crosswordable

  def self.convert_crosswords
    Crossword.unpublished.each do |cw|
      new_ucw = UnpublishedCrossword.new(title: cw.title, description: cw.description, rows: cw.rows, cols: cw.cols, created_at: cw.created_at, updated_at: cw.updated_at, user_id: cw.user_id)
      #handle different attributes
      new_ucw.letters = cw.letters.split('').map{|letter| letter == '_' ? nil : letter}
      
      #clues
      across_clues = cw.cells.map{|c| c.across_clue.try(:content)}
      down_clues = cw.cells.map{|c| c.across_clue.try(:content)}
      new_ucw.across_clues = across_clues
      new_ucw.down_clues = down_clues

      if new_ucw.save
        # cw.destroy
      end
    end
  end
end
