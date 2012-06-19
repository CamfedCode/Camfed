class EpiSurveyorDashboardPage
  include PageObject

  direct_url "#{EnvConfig.get :epi, :url}/dashboard/index"
  expected_title "DataDyne's EpiSurveyor: Dashboard"

  button :import, :id => 'import'
  button :delete, :id => 'delete'
  file_field :file_location, :name => 'uploadsurveyfile'
  button :upload, :text => 'Upload'
  list_item :upload_ok, :text => 'Form uploaded successfully'
  unordered_list :input_area, :class => 'inputarea'
  list_item(:error_message) { |page| page.input_area_element.list_item_element(:index => 7) }

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