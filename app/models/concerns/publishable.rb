module Publishable
  extend ActiveSupport::Concern

  included do
    attr_accessible :published, :published_at

    default_scope {order(published_at: :desc)}
    scope :published, -> {where(published: true)}
    scope :unpublished, -> {where(published: false)}

    scope :standard, -> {where(rows: 15, cols: 15)}
    scope :nonstandard, -> {where.not('(rows = 15) AND (cols = 15)')}

    scope :solved, -> (user_id) {joins(:solutions).where(solutions: {user_id: user_id, is_complete: true}).published.distinct}
    scope :in_progress, -> (user_id) {joins(:solutions).where(solutions: {user_id: user_id, is_complete: false}).distinct}
    scope :unstarted, -> (user_id) {joins(:solutions).where.not(solutions: {user_id: user_id}).published.distinct}

    scope :solo, -> {where(solutions: {team: false})}
    scope :teamed, -> {where(solutions: {team: true})}

    scope :partnered, -> (user_id) {joins(:solution_partnerings).where(solution_partnerings:{user_id: user_id})}


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
      the_word = Word.find_or_create_by(content: word)
      the_word.clues << clue
    end
  end

  def publish!
    letters = self.string_from_cells
    if self.update_attributes(published: true, published_at: Date.today, letters: letters)
      #remove extraneous clues
      self.cells.each do |cell|
        cell.delete_extraneous_cells!
      end
      self.number_cells
      self.generate_words_and_link_clues
    else
    end
  end

end