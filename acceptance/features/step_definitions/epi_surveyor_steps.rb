Given /^there is a '(.+)' survey in EPISurveyor$/ do |survey_name|
  on :epi_surveyor_dashboard_page do |page|
    page.upload_file(EpiSurveyor::create_survey_file(survey_name)) unless page.surveys.include?(survey_name)
    page.surveys.should include survey_name
  end
end

Given /^I am logged into EPISurveyor$/ do
  visit :epi_surveyor_home_page do |page|
    page.login_to_epi
  end
end