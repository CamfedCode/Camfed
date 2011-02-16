class SurveysController < AuthenticatedController
  
  def index
    @surveys = EpiSurveyor::Survey.all
    add_crumb 'Surveys'
  end
  
  def import_selected
    begin
      @surveys = EpiSurveyor::Survey.find(params[:survey_ids])
      import_histories = @surveys.collect{|survey| survey.sync!}.flatten
      set_flash(import_histories, @surveys)
    rescue Exception => error
      flash[:error] = 'Failed to Sync because of ' + error.message
      logger.error "Error in importing Surveys #{@surveys.inspect}. MESSAGE: #{error.message} AT: #{error.backtrace.join(' ')}"
    end
    redirect_to surveys_path
  end

  def sync_with_epi_surveyor
    EpiSurveyor::Survey.sync_with_epi_surveyor
    flash[:notice] = "Updated the list of all surveys from EpiSurveyor"
    redirect_to surveys_path
  end
  
  def search
    @surveys = EpiSurveyor::Survey.where("surveys.name LIKE ?", "%#{params[:query]}%")
    add_crumb 'Surveys', surveys_path
    add_crumb "Search results for: #{params[:query]}"
    render :index
  end
  
  
  private
  def errors_count import_histories
    import_histories.select{|import_history| import_history.sync_errors.present? }.length
  end
  
  def set_flash import_histories, surveys
    survey_names = surveys.map(&:name).join(', ')
    if import_histories.length == 0
      flash[:notice] = "There was no new responses to import for #{survey_names}"
      return
    end

    errors_count = errors_count(import_histories)
    if errors_count > 0
      flash[:error] = "Failed to import #{errors_count} out of #{import_histories.length} new response(s) to #{survey_names}"
    else
      flash[:notice] = "Successfully imported #{import_histories.length} new response(s) to #{survey_names}"  
    end
    
  end
  

end
