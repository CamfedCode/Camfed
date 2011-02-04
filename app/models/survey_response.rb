class SurveyResponse
  include HTTParty
  base_uri 'https://www.episurveyor.org'
  
  attr_accessor :id, :question_answers
  
  def self.find_all_by_survey_id survey_id
    body = Survey.auth.merge(:surveyid => survey_id)
    survey_data = post('/api/surveydata', :body => body, :headers => Survey.headers)
    return [] if survey_data.nil? || survey_data['SurveyDataList'].nil? || survey_data['SurveyDataList']['SurveyData'].nil?
    
    survey_data_hashes = survey_data['SurveyDataList']['SurveyData']
    survey_data_hashes = [] << survey_data_hashes unless survey_data_hashes.is_a?(Array)
    
    survey_data_hashes.collect { |survey_data_hash| from_hash(survey_data_hash)}
  end
  
  def ==(other)
    other.present? && self.id == other.id
  end
  
  def self.from_hash survey_data_hash
    survey_response = SurveyResponse.new
    survey_response.id = survey_data_hash['Id']
    survey_response.question_answers = survey_data_hash
    survey_response
  end
  
  def [](question)
    question_answers[question]
  end
  
end