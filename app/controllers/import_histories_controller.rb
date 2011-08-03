class ImportHistoriesController < AuthenticatedController
  
  def index
    #if params[:survey_id].present?
    #  @survey = EpiSurveyor::Survey.find(params[:survey_id])
    #  @import_histories = @survey.import_histories
    #else
    #  @import_histories = ImportHistory.all
    #end
    @import_histories = ImportHistory.get_by_status(params[:survey_id],params[:status])

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
    redirect_to :back
  end
end
