namespace :cleanup do
  desc "Delete stale draft solutions (<10% complete, not updated in 1+ year)"
  task stale_solutions: :environment do
    cutoff = 1.year.ago
    dry_run = ENV["DRY_RUN"] != "false"

    # solvable_cells = non-void characters (everything except '_')
    # filled_cells   = non-void, non-blank characters (actual letters entered)
    stale = Solution.incomplete
      .where("updated_at < ?", cutoff)
      .where(<<~SQL)
        length(replace(replace(letters, ' ', ''), '_', '')) <
        0.1 * length(replace(letters, '_', ''))
      SQL

    count = stale.count

    if dry_run
      puts "[DRY RUN] Would delete #{count} stale draft solutions (updated before #{cutoff.to_date})"
      if count > 0
        sample = stale.limit(10).pluck(:id, :user_id, :crossword_id, :updated_at)
        sample.each do |id, uid, cid, updated|
          puts "  Solution ##{id} — user #{uid}, crossword #{cid}, last updated #{updated.to_date}"
        end
        puts "  ... and #{count - sample.size} more" if count > sample.size
      end
      puts "\nRun with DRY_RUN=false to actually delete."
    else
      stale.in_batches(of: 500).delete_all
      puts "Deleted #{count} stale draft solutions."
    end
  end
end
