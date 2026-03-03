namespace :phrases do
  desc "Backfill Phrase records for existing clues"
  task backfill: :environment do
    count = 0
    Clue.where.not(content: [Clue::DEFAULT_CONTENT, nil, ''])
        .where(phrase_id: nil)
        .find_in_batches(batch_size: 500) do |batch|
      # Batch-load existing phrases for this group of clues
      texts = batch.map { |c| c.content.strip.downcase }.uniq
      phrase_cache = Phrase.where("LOWER(content) IN (?)", texts)
                          .index_by { |p| p.content.strip.downcase }

      updates = batch.map do |clue|
        key = clue.content.strip.downcase
        phrase = phrase_cache[key] ||= Phrase.find_or_create_by_content(clue.content)
        [clue.id, phrase.id]
      end

      # Bulk update phrase_id in one query per batch
      Clue.where(id: updates.map(&:first)).update_all(phrase_id: nil) # no-op to reset
      updates.group_by(&:last).each do |phrase_id, pairs|
        Clue.where(id: pairs.map(&:first)).update_all(phrase_id: phrase_id)
      end

      count += batch.size
      puts "  Linked #{count} clues so far..."
    end
    puts "Done! Linked #{count} clues to phrases (#{Phrase.count} total phrases)"
  end
end
