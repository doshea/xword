# Converts an UnpublishedCrossword into a published Crossword.
# Extracted from UnpublishedCrosswordsController#publish.
#
# Usage:
#   crossword = CrosswordPublisher.publish(ucw)
#   # Returns the published Crossword.
#   # Raises CrosswordPublisher::BlankCellsError if any cells are blank.
#   # Raises ActiveRecord::RecordInvalid on save failures (rolls back txn).
#   # Destroys the UCW on success.
class CrosswordPublisher
  class BlankCellsError < StandardError; end

  def self.publish(ucw)
    validate_complete!(ucw)

    Crossword.transaction do
      crossword = create_crossword(ucw)
      apply_letters(crossword, ucw)
      assign_clues(crossword, ucw)
      clean_up_cells(crossword)
      apply_circles(crossword, ucw)
      ucw.destroy!
      crossword
    end
  end

  # Raises BlankCellsError if any non-void cells are still blank.
  def self.validate_complete!(ucw)
    blank_count = ucw.letters.count { |l| !l.nil? && l.blank? }
    return if blank_count == 0

    raise BlankCellsError,
      "#{blank_count} #{'cell'.pluralize(blank_count)} still blank"
  end
  private_class_method :validate_complete!

  def self.create_crossword(ucw)
    Crossword.create!(
      title: ucw.title,
      description: ucw.description,
      rows: ucw.rows,
      cols: ucw.cols,
      user: ucw.user
    )
  end
  private_class_method :create_crossword

  def self.apply_letters(crossword, ucw)
    rebus_map = {}
    letters_string = ucw.letters.each_with_index.map do |l, i|
      if l.nil?
        '_'
      elsif l.length > 1
        rebus_map[i.to_s] = l
        l[0]
      else
        l
      end
    end.join

    crossword.set_contents(letters_string, new_rebus_map: rebus_map.presence)
    crossword.number_cells
  end
  private_class_method :apply_letters

  def self.assign_clues(crossword, ucw)
    crossword.cells.reload.each do |cell|
      idx = cell.index - 1
      if cell.is_across_start && ucw.across_clues[idx].present?
        cell.across_clue.update!(content: ucw.across_clues[idx])
      end
      if cell.is_down_start && ucw.down_clues[idx].present?
        cell.down_clue.update!(content: ucw.down_clues[idx])
      end
    end
  end
  private_class_method :assign_clues

  def self.clean_up_cells(crossword)
    crossword.cells.each { |cell| cell.delete_extraneous_cells! }
    crossword.generate_words_and_link_clues
  end
  private_class_method :clean_up_cells

  def self.apply_circles(crossword, ucw)
    return unless ucw.circles.present? && ucw.circles.chars.any? { |c| c != ' ' && c != '0' }

    crossword.circles_from_array(ucw.circles.chars.map(&:to_i))
  end
  private_class_method :apply_circles
end
