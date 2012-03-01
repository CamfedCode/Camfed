Given /^I am logged into Camfed$/ do
  visit :camfed_signin_page do |page|
    page.signin_to_camfed
  end
end

Given /^there is no '(.+)' survey in Camfed$/ do |survey_name|
  on :camfed_surveys_page do |page|
    page.delete_survey(survey_name) if page.contains_survey?(survey_name)
  end
end

When /^I refresh the surveys list in Camfed$/ do
  on :camfed_surveys_page do |page|
    page.refresh_surveys
  end
end

When /^I delete the '(.+)' survey in Camfed$/ do |survey_name|
  on :camfed_surveys_page do |page|
    page.delete_survey(survey_name)
  end
end

Then /^I should see the '(.+)' survey in Camfed$/ do |survey_name|
  on :camfed_surveys_page do |page|
    page.contains_survey?(survey_name).should be_true
  end
end

Then /^I should not see the '(.+)' survey in Camfed$/ do |survey_name|
  on :camfed_surveys_page do |page|
    page.contains_survey?(survey_name).should be_false
  end
end

Given /^the '(.+)' Salesforce object is disabled$/ do |name|
  visit :camfed_salesforce_objects_page do |page|
    page.disable_salesforce_object name
    page.notice.should == "Successfully disabled #{name}"
  end
end

When /^I enabled the '(.+)' Salesforce object$/ do |name|
  visit :camfed_salesforce_objects_page do |page|
    page.enable_salesforce_object name
    page.notice.should == "Successfully enabled #{name}"
  end
end

Then /^the '(.+)' Salesforce object is enabled$/ do |name|
  visit :camfed_salesforce_objects_page do |page|
    page.disable_salesforce_object_link(name).should exist
  end
end