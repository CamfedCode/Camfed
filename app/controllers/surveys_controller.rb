class SurveysController < AuthenticatedController
  
  def index
    start_date=params[:start_date]
    end_date=params[:end_date]
    start_date=nil if start_date.nil? or start_date.empty?
    end_date=nil if end_date.nil? or end_date.empty?
    starts_with = params[:start_with]
    starts_with = nil if starts_with.nil? or starts_with.empty?

    if !start_date.nil? and !end_date.nil?
      end_date = end_date.to_time.advance(:days => 1).to_date
      @surveys = EpiSurveyor::Survey.ordered.modified_between(start_date, end_date).page(params[:page])
    else
      if !starts_with.nil?
        @surveys = EpiSurveyor::Survey.ordered.starting_with(starts_with).page(params[:page])
      else
        @surveys = EpiSurveyor::Survey.ordered.page(params[:page])
      end
    end
    add_crumb 'Surveys'
  end
  
  def edit
    @survey = EpiSurveyor::Survey.find params[:id]
    add_crumb 'Surveys', surveys_path
    add_crumb @survey.name
  end
  
  def update
    @survey = EpiSurveyor::Survey.find params[:id]
    
    if @survey.update_attributes(params[:epi_surveyor_survey])
      flash[:notice] = "The sync results for #{@survey.name} will now be sent to #{@survey.notification_email}."
      redirect_to root_path
    else
      flash[:error] = "Could not update the notification email."
      logger.error "Error in saving survey. MESSAGE: #{@survey.errors.inspect}"
      render 'edit'
    end    
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
  
  def destroy_selected
    begin
      @surveys = EpiSurveyor::Survey.find(params[:survey_ids])
      @surveys.collect{|survey| survey.destroy}
      flash[:notice] = "Successfully Deleted #{@surveys.length} surveys."
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
    @surveys = EpiSurveyor::Survey.where("LOWER(surveys.name) LIKE ?", "%#{params[:query].downcase}%").page(params[:page]).ordered
    add_crumb 'Surveys', surveys_path
    add_crumb "Search results for: #{params[:query]}"
    render :index
  end

  def update_mapping_status
    survey = EpiSurveyor::Survey.find params[:id]
    survey.update_attributes!(:mapping_status => params[:mapping_status])
    flash[:notice] = "Mapping status updated"
    redirect_to survey_mappings_path(survey)
  end
  
  private
  def errors_count import_histories
    import_histories.select{|import_history| import_history.sync_errors.present? }.length
  end
  
  def set_flash import_histories, surveys
    if import_histories.length == 0
      flash[:notice] = "There was no new responses to import for selected surveys."
      return
    end

    errors_count = errors_count(import_histories)
    if errors_count > 0
      flash[:error] = "Failed to import #{errors_count} out of #{import_histories.length} new response(s) to selected surveys."
    else
      flash[:notice] = "Successfully imported #{import_histories.length} new response(s) to selected surveys."  
    end
    
  end
  

end
