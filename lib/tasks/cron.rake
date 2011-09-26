desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  ENV['SHOWSOAP'] = 'true'
  Rails.logger.info "Running nightly CRON job..."
  EpiSurveyor::Survey.sync_and_notify!
end