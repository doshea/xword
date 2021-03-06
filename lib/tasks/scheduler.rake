# All Rake tasks in this file can be used by Heroku's Scheduler add-on
namespace :nyt do

  task :tester => :environment do
    puts 'Hello'
  end

  task :latest_nyt => :environment do
    begin
      puts "Getting latest NYT puzzle and adding it to db"
      Crossword.add_latest_nyt_puzzle
      puts "\nDone."
    rescue
      AdminMailer.nyt_upload_error_email.deliver
    end
  end

  task :latest_nyt_to_github => :environment do
    Crossword.record_date_on_github(Date.today)
  end

  task :remove_duplicate_nyt_puzzles => :environment do
    User.where(username: 'nytimes').crosswords.each do |cw|
      if Crossword.where(title: cw.title).length > 1
        lookalikes = Crossword.where(title: cw.title)
        max_created_at = lookalikes.max_by {|p| p.created_at}
        lookalikes.each do |lookalike|
            lookalike.destroy unless (lookalike.created_at == max_created_at)
        end
      end
    end
  end

  task :remove_unworked_solutions => :environment do

  end

end