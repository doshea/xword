# All Rake tasks in this file can be used by Heroku's Scheduler add-on
task :latest_nyt => :environment do
  puts "Getting latest NYT puzzle and adding it to db"
  Crossword.add_latest_nyt_puzzle
  puts "\nDone."
end