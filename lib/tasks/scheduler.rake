# All Rake tasks in this file can be used by Heroku's Scheduler add-on
namespace :nyt do

  task :tester => :environment do
    puts 'Hello'
  end

  task :latest_nyt => :environment do
    puts "Getting latest NYT puzzle and adding it to db"
    Crossword.add_latest_nyt_puzzle
    puts "\nDone."
  end

  task :remove_duplicate_nyt_puzzles => :environment do
    User.where(username: 'nytimes').crosswords.each do |cw|
      if Crossword.where(title: cw.title).length > 1
        lookalikes = Crossword.where(title: cw.title)
        max_created_at = lookalikes.max_by {|p| p.created_at}
        lookalikes.each do |lookalike|
            lookalike.delete unless (lookalike.created_at == max_created_at)
        end
      end
    end
  end
end
