class CamfedSurveysPage
  include PageObject

  expected_title 'Camfed - Surveys'

  link :refresh_surveys, :text => 'Refresh Surveys List from EpiSurveyor'
  button :delete_selected, :value => 'Delete Selected'

  def contains_survey? survey_name
    browser.span(:text => survey_name).exists?
  end

  def delete_survey survey_name
    browser.span(:text => survey_name).parent.checkbox.click
    browser.confirm(true) do
      delete_selected
    end
  end
end