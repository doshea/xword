# Fix clues that were double-encoded when ASCII-8BIT strings from HTTParty
# were passed through Loofah's strip_tags (which re-encodes Latin-1 → UTF-8).
# Signature: "Ã" followed by another high byte (e.g., "Ã©" = double-encoded "é").
class FixDoubleEncodedClues < ActiveRecord::Migration[8.1]
  def up
    # Find clues containing the double-encoding signature (Ã followed by
    # a second byte that's part of a UTF-8 multi-byte sequence).
    Clue.where("content LIKE '%Ã%'").find_each do |clue|
      fixed = clue.content.encode('ISO-8859-1').force_encoding('UTF-8')
      if fixed.valid_encoding? && fixed != clue.content
        clue.update_column(:content, fixed)
      end
    rescue Encoding::UndefinedConversionError
      # Content contains characters outside ISO-8859-1 range — skip,
      # the "Ã" is likely legitimate UTF-8 (e.g., Portuguese names).
      next
    end
  end

  def down
    # Not reversible — the double-encoding was data corruption, not intentional.
  end
end
