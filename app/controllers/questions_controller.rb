class QuestionsController < ApplicationController
  add_crumb 'Home', '/'
  def index
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    @questions = @survey.questions
    add_crumb 'Surveys', surveys_path
    add_crumb 'Questions'
  end

end
