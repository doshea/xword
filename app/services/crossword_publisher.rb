# Publishes an UnpublishedCrossword into a full Crossword.
# Extracted from UnpublishedCrosswordsController#publish.
class CrosswordPublisher
  class BlankCellsError < StandardError; end

  # Publish the given UCW. Returns the new Crossword.
  # Raises BlankCellsError if any non-void cells are blank.
  # Raises ActiveRecord::RecordInvalid (or other) on save failure — all wrapped in a transaction.
  def self.publish(ucw)
    blank_count = ucw.letters.count { |l| !l.nil? && l.blank? }
    if blank_count > 0
      raise BlankCellsError, "#{blank_count} #{'cell'.pluralize(blank_count)} still blank"
    end

    Crossword.transaction do
      letters_string = ucw.letters.map { |l| l.nil? ? '_' : l }.join

      crossword = Crossword.create!(
        title: ucw.title,
        description: ucw.description,
        rows: ucw.rows,
        cols: ucw.cols,
        user: ucw.user
      )

      crossword.set_contents(letters_string)
      crossword.number_cells

      crossword.cells.reload.each do |cell|
        idx = cell.index - 1
        if cell.is_across_start && ucw.across_clues[idx].present?
          cell.across_clue.update!(content: ucw.across_clues[idx])
        end
        if cell.is_down_start && ucw.down_clues[idx].present?
          cell.down_clue.update!(content: ucw.down_clues[idx])
        end
      end

      crossword.cells.each { |cell| cell.delete_extraneous_cells! }
      crossword.generate_words_and_link_clues

      if ucw.circles.present? && ucw.circles.chars.any? { |c| c != ' ' && c != '0' }
        crossword.circles_from_array(ucw.circles.chars.map(&:to_i))
      end

      ucw.destroy!
      crossword
    end
  end
end
