class QuestionsController < AuthenticatedController

  def index
    begin
      @survey = EpiSurveyor::Survey.find(params[:survey_id])
      @questions = @survey.questions
    rescue Exception => error
      flash[:error] = "Could not fetch questions from EpiSurveyor because of #{error.message}"
      logger.error "Error in fetching questions from EpiSurveyor. #{error.message} #{error.backtrace.join(' ')}"
      redirect_to surveys_path
    end
    
    add_crumb 'Surveys', surveys_path
    add_crumb 'Questions'
  end

end
