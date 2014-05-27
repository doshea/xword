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
    Crossword.record_on_github(Date.today)
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

  # should only be run on local environment
  task :record => :environment do
    latest = HTTParty.get("http://www.xwordinfo.com/JSON/Data.aspx")
    latest_json = latest.to_json
    # target_path = 'lib/assets/nyt_puzzle_history.rb'

    rb_target_path = '../nyt_puzzle_history/nyt_puzzle_history.rb'
    json_target_path = '../nyt_puzzle_history/nyt_puzzle_history.json'

    File.open(rb_target_path, 'a') do |f|
      File.truncate(rb_target_path, File.size(rb_target_path)-3)
      f.puts ','
      f.print '  '
      f.puts latest
      f.puts ']'
    end
    puts "RB: Puzzle Recorded."
    File.open(json_target_path, 'a') do |f|
      File.truncate(json_target_path, File.size(json_target_path)-3)
      f.puts ','
      f.print '  '
      f.puts latest_json
      f.puts ']'
    end

    puts "JSON: Puzzle Recorded."
  end

end