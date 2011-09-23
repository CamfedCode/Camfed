desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  ENV['SHOWSOAP'] = 'true'
  EpiSurveyor::Survey.sync_and_notify!
end