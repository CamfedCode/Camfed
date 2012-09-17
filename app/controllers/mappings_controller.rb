class MappingsController < AuthenticatedController

  def index
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    @questions_for_select = @survey.questions.map do |question|
      [question.name, question.name]
    end
    @sfobjects_for_select = Salesforce::Base.where(:enabled => true).map do |sfobject|
      [sfobject.name, sfobject.label]
    end
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings'
  end

  def source
    @survey  = EpiSurveyor::Survey.find(params[:survey_id])
    @surveys = EpiSurveyor::Survey.all.reject{|survey| survey == @survey}.sort_by{|survey| survey.name }
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings', survey_mappings_path(@survey)
    add_crumb 'Clone from Another Survey'
  end

  def multimap
    @base_survey = EpiSurveyor::Survey.find(params[:survey_id])
    @target_surveys = @base_survey.find_potential_list_of_target_surveys_for_cloning_mappings_into
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings', survey_mappings_path(@base_survey)
    add_crumb 'Clone Mapping Into Multiple Surveys'
  end

  def multiclone
    @base_survey = EpiSurveyor::Survey.find(params[:survey_id])
    target_surveys = EpiSurveyor::Survey.find(params[:selected_surveys])

    @status_messages = []
    some_error_occurred = false

    target_surveys.each do |survey|
      begin
        survey.clone_mappings_from! @base_survey
        @status_messages << Status.new(survey.name, false, "-")
      rescue MappingCloneException => mapping_clone_error
        @status_messages << Status.new(survey.name, true, "Missing questions: #{mapping_clone_error.message}")
        some_error_occurred=true
      rescue Exception => error
        @status_messages << Status.new(survey.name, true, error.message)
        some_error_occurred=true
      end
    end

    if some_error_occurred
      flash[:error] = "Cloned operation had some failures."
    else
      flash[:notice] = "Cloned operation completed successfully."
    end

    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings', survey_mappings_path(@base_survey)

  end

  def clone
    begin
      source_survey = EpiSurveyor::Survey.find(params[:source_survey_id])
      @survey = EpiSurveyor::Survey.find(params[:survey_id])
      @survey.clone_mappings_from! source_survey
      flash[:notice] = "The mappings were cloned from #{source_survey.name}"
    rescue MappingCloneException => mapping_clone_error
      flash[:error] = "Could not clone because of these missing questions in #{@survey.name}: #{mapping_clone_error.message}"
    rescue Exception => error
      flash[:error] = "Could not clone mappings from #{source_survey.name} because of #{error.message}"
      logger.error "Could not clone mappings from #{source_survey.name} because of #{error.message} #{error.backtrace.join(' ')}"
    end
    
    redirect_to survey_mappings_path(params[:survey_id])
  end

end
