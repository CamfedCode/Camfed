class SurveysController < AuthenticatedController
  add_crumb 'Home', '/'
  
  def index
    @surveys = EpiSurveyor::Survey.all
    add_crumb 'Surveys'
  end
  
  def import
    begin
      @survey = EpiSurveyor::Survey.find(params[:id])
      import_histories = @survey.sync!
      @survey.touch(:last_imported_at)      
      errors_count = import_histories.select{|import_history| import_history.sync_errors.present? }.length       
      if errors_count > 0
        flash[:error] = "The import completed with errors in #{errors_count} out of #{import_histories.length} new response(s) to #{@survey.name}"
      else
        flash[:notice] = "Successfully synced #{import_histories.length} new response(s) to #{@survey.name}"  
      end
    rescue Exception => error
      flash[:error] = 'Failed to Sync because of ' + error.message
      logger.error "Error in importing Survey #{@survey}. MESSAGE: #{error.message} AT: #{error.backtrace.join(' ')}"
    end
    
    redirect_to surveys_path
  end

  def sync_with_epi_surveyor
    EpiSurveyor::Survey.sync_with_epi_surveyor
    flash[:notice] = "Updated the list of all surveys from EpiSurveyor"
    redirect_to surveys_path
  end

end
