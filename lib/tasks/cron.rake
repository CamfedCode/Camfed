desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  EpiSurveyor::Survey.sync_and_notify!
end