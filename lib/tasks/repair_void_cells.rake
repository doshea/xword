# Repair unpublished crosswords where integer 0 was saved as "0" string
# instead of nil (void). This happened because JS sent integer 0 for void
# cells and Ruby's `0 == "0"` is false (no type coercion).
#
# Run: bundle exec rails repair:void_cells
# Safe to run multiple times (idempotent).

namespace :repair do
  desc 'Convert "0" letter entries back to nil in unpublished crosswords'
  task void_cells: :environment do
    fixed = 0
    UnpublishedCrossword.find_each do |ucw|
      next unless ucw.letters.is_a?(Array)
      dirty = false
      ucw.letters.each_with_index do |letter, i|
        if letter == "0"
          ucw.letters[i] = nil
          dirty = true
        end
      end
      if dirty
        ucw.update_column(:letters, ucw.letters)
        fixed += 1
        puts "Fixed UCW ##{ucw.id} (#{ucw.title})"
      end
    end
    puts "Done. Fixed #{fixed} unpublished crossword(s)."
  end
end
