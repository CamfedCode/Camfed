class SurveysController < ApplicationController
  add_crumb 'Home', '/'
  
  def index
    @surveys = EpiSurveyor::Survey.all
    add_crumb 'Surveys'
  end
  
  def import
    @survey = EpiSurveyor::Survey.find_by_name(params[:survey_name])
    @survey.sync!
    flash[:notice] = "Synced #{@survey.name}"
    redirect_to surveys_path
  end

  def sync_with_epi_surveyor
    EpiSurveyor::Survey.sync_with_epi_surveyor
    flash[:notice] = "Updated the list of all surveys from EpiSurveyor"
    redirect_to surveys_path
  end

end
