class MappingsController < ApplicationController
  add_crumb 'Home', '/'

  def index
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings'
  end

end
