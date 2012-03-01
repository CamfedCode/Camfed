require 'watir-page-helper'

module WatirPageHelper::EpiSurveyorDashboardPage
  extend WatirPageHelper::ClassMethods

  direct_url "#{EnvConfig.get :epi, :url}/dashboard/index"
  expected_title "DataDyne's EpiSurveyor: Dashboard"

  button :import, :id => 'import'
  button :delete, :id => 'delete'
  file_field :file_location, :name => 'uploadsurveyfile'
  button :upload, :text => 'Upload'
  li :upload_ok, :text => 'Form uploaded successfully'

  def upload_file file_path
    import
    self.file_location = file_path
    upload
  end

  def surveys
    browser.trs(:class => 'row').collect {|tr| tr.td.text}
  end

  def survey_td survey_name
    browser.td(:text => survey_name)
  end

  def delete_survey
    browser.confirm(true) do
      delete
    end
  end
end