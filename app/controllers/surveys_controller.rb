class SurveysController < ApplicationController
  def index
    @surveys = EpiSurveyor::Survey.all
  end
  
  def import
    @survey = EpiSurveyor::Survey.find_by_name(params[:survey_name])
    @survey.sync!
    flash[:notice] = "Synced #{@survey.name}"
    redirect_to surveys_path
  end

end
