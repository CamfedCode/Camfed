class ImportHistoriesController < AuthenticatedController
  add_crumb 'Home', '/'
  
  def index
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    @import_histories = @survey.import_histories
    add_crumb 'Surveys', surveys_path
    add_crumb 'Histories'
  end

  def show
    @import_history = ImportHistory.find(params[:id])
    add_crumb 'Surveys', surveys_path
    add_crumb 'Histories', survey_import_histories_path(@import_history.survey_id)
    add_crumb 'History'
  end

  def destroy
    @import_history = ImportHistory.find(params[:id])
    @import_history.destroy
    flash[:notice] = 'The record was successfully deleted'
    redirect_to(survey_import_histories_url(@import_history.survey_id))
  end
end
