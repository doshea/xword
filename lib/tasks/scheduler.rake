# All Rake tasks in this file can be used by Heroku's Scheduler add-on
namespace :nyt do

  task :latest_nyt => :environment do
    begin
      puts "Getting latest NYT puzzle and adding it to db"
      response = NytPuzzleFetcher.from_xwordinfo
      NytPuzzleImporter.import(response.parsed_response)
      NytGithubRecorder.record_on_github(response.body, Date.today)
      puts "\nDone."
    rescue
      AdminMailer.nyt_upload_error_email.deliver_now
    end
  end

  task :latest_nyt_to_github => :environment do
    NytGithubRecorder.record_date_on_github(Date.today)
  end

end
