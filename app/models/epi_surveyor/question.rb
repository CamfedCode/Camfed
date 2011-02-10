module EpiSurveyor
  class Question
    include HTTParty
    base_uri 'https://www.episurveyor.org'
    
    attr_accessor :id, :prompt, :name, :survey
    
    def self.find_all_by_survey(survey)
      body = Survey.auth.merge(:surveyid => survey.id)
      response = post('/api/questions', :body => body, :headers => Survey.headers)
      return [] if response.nil? || response['Questions'].nil? || response['Questions']['Question'].nil?
      
      questions = []
      raw_questions = response['Questions']['Question']
      
      raw_questions = [raw_questions] unless raw_questions.is_a?(Array)
      
      raw_questions.each do |question_hash|
        question = Question.new
        question.id = question_hash['Id']
        question.name = question_hash['Name']
        question.prompt = question_hash['Prompt']
        question.survey = survey
        questions << question
      end
      questions
    end
    
    
    def ==(other)
      other.present? && self.id == other.id
    end
    
    
  end
end