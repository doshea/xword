namespace :phrases do
  desc "Backfill Phrase records for existing clues"
  task backfill: :environment do
    count = 0
    Clue.where.not(content: [Clue::DEFAULT_CONTENT, nil, ''])
        .where(phrase_id: nil)
        .find_each do |clue|
      phrase = Phrase.find_or_create_by_content(clue.content)
      clue.update_column(:phrase_id, phrase.id)
      count += 1
    end
    puts "Linked #{count} clues to phrases (#{Phrase.count} total phrases)"
  end
end
