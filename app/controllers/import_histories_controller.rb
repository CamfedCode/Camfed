class ImportHistoriesController < AuthenticatedController
  
  def index
    start_date=params[:start_date]
    start_date=nil if start_date.nil? or start_date.empty?
    end_date=params[:end_date]
    end_date=nil if end_date.nil? or end_date.empty?
    end_date=Time.now if end_date.nil? and !start_date.nil?
    @import_histories = ImportHistory.get_by_filter(params[:survey_id],params[:status],start_date,end_date)

    add_crumb 'Surveys', surveys_path
    add_crumb 'Histories'
  end

  def show
    @import_history = ImportHistory.find(params[:id])
    add_crumb 'Surveys', surveys_path
    add_crumb 'Histories', survey_import_histories_path(@import_history.survey_id)
    add_crumb 'History'
  end
  
  def destroy_selected
    begin
      @import_histories = ImportHistory.find(params[:import_history_ids])
      @import_histories.collect{|import_history| import_history.destroy}
      flash[:notice] = "Successfully Deleted #{@import_histories.length} import histories."
    rescue Exception => error
      flash[:error] = 'Failed to Sync because of ' + error.message
      logger.error "Error in importing histories #{@import_histories.inspect}. MESSAGE: #{error.message} AT: #{error.backtrace.join(' ')}"
    end
    redirect_to :back
  end
end
