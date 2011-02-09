module EpiSurveyor
  class SurveyResponse
    include HTTParty
    base_uri 'https://www.episurveyor.org'
  
    attr_accessor :id, :survey, :question_answers

    def initialize
      self.question_answers = {}
    end
  
    def ==(other)
      other.present? && self.id == other.id
    end
  
    def [](question)
      question_answers[question]
    end

    def []=(question, answer)
      question_answers[question] = answer
    end
    
    def self.find_all_by_survey survey
      body = Survey.auth.merge(:surveyid => survey.id)
      survey_data = post('/api/surveydata', :body => body, :headers => Survey.headers)
      return [] if survey_data.nil? || survey_data['SurveyDataList'].nil? || survey_data['SurveyDataList']['SurveyData'].nil?
    
      survey_data_hashes = survey_data['SurveyDataList']['SurveyData']
      survey_data_hashes = [] << survey_data_hashes unless survey_data_hashes.is_a?(Array)
    
      survey_data_hashes.collect do |survey_data_hash|
        survey_response = from_hash(survey_data_hash)
        survey_response.survey = survey
        survey_response
      end
    end

    def self.from_hash survey_data_hash
      survey_response = SurveyResponse.new
      survey_response.id = survey_data_hash['Id']
      survey_response.question_answers = survey_data_hash
      survey_response
    end

    def sync! mapping
      return if synced?
      
      sf_objects = []
      mapping.each_pair do |sales_force_object_name, field_mapping|
        sales_force_object = Salesforce::ObjectFactory.create(sales_force_object_name)
        field_mapping.each_pair do |field_name, question|
          sales_force_object[field_name] = self[question]
        end
        sales_force_object.sync!
      end
      ImportHistory.create(:survey_id => survey.id, :survey_name => survey.name, :survey_response_id => self.id)
    end
    
    def synced?
      ImportHistory.exists?(:survey_id => survey.id, :survey_response_id => self.id)
    end
  
  end
end