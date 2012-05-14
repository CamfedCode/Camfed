#!/usr/bin/env ruby

$: << File.dirname(__FILE__)+'/../lib'

if ARGV.count < 3
  puts 'usage: import <environment> <svy file> <csv file>'
  puts '  eg. import local sample.svy surveys.csv'
  exit 1
end

ENVIRONMENT = ARGV.shift.to_sym
svy_path = ARGV.shift
csv_path = ARGV.shift

raise "Could not locate survey file '#{svy_path}'" unless File.exists? svy_path
raise "Could not locate csv file '#{svy_path}'" unless File.exists? csv_path

require 'watir-webdriver'
require 'watir-webdriver/extensions/alerts'
require 'page-object'
require 'epi_surveyor'
require 'page-object/page_factory'
require 'env_config'
require 'pages'

driver = (ENV['WEB_DRIVER'] || :firefox).to_sym
client = Selenium::WebDriver::Remote::Http::Default.new

@browser = Watir::Browser.new driver, :http_client => client

include PageObject::PageFactory

visit EpiSurveyorHomePage do |page|
  page.login_to_epi
end

File.readlines(csv_path).each do |line|
  survey_name = line.chomp
  on EpiSurveyorDashboardPage do |page|
    unless page.surveys.include?(survey_name)
      puts "Creating survey: '#{survey_name}'"
      page.upload_file(EpiSurveyor::create_survey_file(survey_name, svy_path))
    else
      puts "Skipping survey: '#{survey_name}' as it already exists!"
    end
  end
end

@browser.close