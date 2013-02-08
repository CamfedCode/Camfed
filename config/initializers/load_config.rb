APP_CONSTANTS = YAML.load_file("#{Rails.root}/config/app_constants.yml")
TWILIO_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/twilio.yml")).result)
