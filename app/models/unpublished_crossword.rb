# == Schema Information
#
# Table name: unpublished_crosswords
#
#  id               :integer          not null, primary key
#  title            :string           default("Untitled"), not null
#  letters          :text             default([]), is an Array
#  description      :text
#  rows             :integer
#  cols             :integer
#  user_id          :integer
#  circles          :text             default("{}")
#  potential_words  :text             default([]), is an Array
#  created_at       :datetime
#  updated_at       :datetime
#  across_clues     :text             default([]), is an Array
#  down_clues       :text             default([]), is an Array
#  mirror_voids     :boolean          default(TRUE)
#  circle_mode      :boolean          default(FALSE)
#  one_click_void   :boolean          default(FALSE)
#  multiletter_mode :boolean          default(FALSE)
#

class UnpublishedCrossword < ActiveRecord::Base
  include Crosswordable

  before_create :populate_arrays

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

  #TODO make this work
  def letters_to_clue_numbers
    letter_voids = letters.map{|letter| letter.nil?}
    counter = 1

    across_a = []
    down_a = []

    letter_voids.each_with_index do |v, i|
      counted = false
      #across
      #check if in left column
      if (i % cols > 0)
        left_i = i-1
        if letter_voids[left_i]
          across_a << counter
          counted = true
        else
          across_a << nil
        end
      else
        across_a << counter
        counted = true
      end
      #down
      #check if in top row
      if i >= cols
        top_i = i-cols
        if letter_voids[top_i]
          down_a << counter
          counted = true
        else
          down_a << nil
        end
      else
        down_a << counter
        counted = true
      end
      counter += 1 if counted
    end

    {across: across_a, down: down_a}
  end

  def add_potential_word(word) 
    if potential_words.include? word
      false
    else
      potential_words << word
      potential_words.sort!{|x,y| y.length <=> x.length}
      save
    end
  end

  def remove_potential_word(word)
    potential_words.delete word
    save
  end

  private
  def populate_arrays
    self.letters = [''] * rows * cols
    self.circles = ' ' * rows * cols
    self.across_clues = self.down_clues = [nil] * rows * cols
  end
end
