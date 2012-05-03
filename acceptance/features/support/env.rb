$: << File.dirname(__FILE__)+'/../../lib'
require 'epi_surveyor'

require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'page-object'
require 'page-object/page_factory'

World PageObject::PageFactory

ENVIRONMENT = (ENV['ENVIRONMENT'] || 'local').to_sym
raise "You need to create a configuration file named '#{ENVIRONMENT}.yml' under lib/config" unless File.exists? "#{File.dirname(__FILE__)}/../../lib/config/#{ENVIRONMENT}.yml"

require 'env_config'
World EpiSurveyor
World EnvConfig

require 'pages.rb'

driver = (ENV['WEB_DRIVER'] || :firefox).to_sym
client = Selenium::WebDriver::Remote::Http::Default.new
client.timeout = 180

browser = Watir::Browser.new driver, :http_client => client

Before { @browser = browser }

After do |scenario|
  if scenario.failed?
    Dir::mkdir('screenshots') if not File.directory?('screenshots')
    screenshot = "./screenshots/FAILED_#{scenario.name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"
    @browser.driver.save_screenshot(screenshot)
    embed screenshot, 'image/png'
  end
  @browser.cookies.clear
end

at_exit { browser.close }