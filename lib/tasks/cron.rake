desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  railsenv = ENV['RAILS_ENV']
  Rails.logger.info("RAILS_ENV=#{railsenv}")
  ENV['SHOWSOAP'] = 'true'
  EpiSurveyor::Survey.sync_and_notify!
end