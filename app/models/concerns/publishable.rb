module Publishable
  extend ActiveSupport::Concern

  included do
    attr_accessible :published, :date_published

    scope :published, -> {where(published: true)}
    scope :unpublished, -> {where(published: false)}
  end

  #Takes an existing crossword puzzle and figures out all of the words in that crossword by cell.
  #Then constructs a hash whose keys are the words and whose values are the clues to those words
  def get_words_hsh
    word_clues = {}
    across_starts = self.cells.across_start_cells.asc_indices
    across_starts.each do |across_start|
      word = ''
      current = across_start
      clue = current.across_clue
      while current && !current.is_void do
        word += current.letter
        current = current.right_cell
      end
      word_clues[word] = clue
    end
    down_starts = self.cells.down_start_cells.asc_indices
    down_starts.each do |down_start|
      word = ''
      current = down_start
      clue = current.down_clue
      while current && !current.is_void do
        word += current.letter
        current = current.below_cell
      end
      word_clues[word] = clue
    end
    word_clues
  end

  def generate_words_and_link_clues
    words_hsh = self.get_words_hsh

    words_hsh.each do |word, clue|
      the_word = Word.find_or_create_by_content(word)
      the_word.clues << clue
    end
  end

  def publish!
    if self.update_attribute(:published, true)
      #remove extraneous clues
      self.cells.each do |cell|
        cell.delete_extraneous_cells!
      end
      self.generate_words_and_link_clues
    else
    end
  end

end