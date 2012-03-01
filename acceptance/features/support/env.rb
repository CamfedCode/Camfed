$: << File.dirname(__FILE__)+'/../../lib'
require 'epi_surveyor'

require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'watir-page-helper/commands'

World WatirPageHelper::Commands

ENVIRONMENT = (ENV['ENVIRONMENT'] || 'local').to_sym
raise "You need to create a configuration file named '#{ENVIRONMENT}.yml' under lib/config" unless File.exists? "#{File.dirname(__FILE__)}/../../lib/config/#{ENVIRONMENT}.yml"

require 'env_config'
World EpiSurveyor

World EnvConfig

WatirPageHelper.create

After do
  WatirPageHelper.browser.cookies.clear
end

at_exit do
  WatirPageHelper.close
end