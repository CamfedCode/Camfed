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

    def sync! object_mappings
      return if synced?
      sync_errors = []
      sf_objects = []
      object_mappings.each do |object_mapping|
        begin
          salesforce_object(object_mapping).sync!
        rescue Exception => error
          sync_errors << error
        end
      end
      
      error_message = sync_errors.collect{|error| error.message}.join(" AND ")
      ImportHistory.create!(:survey_id => survey.id, :survey_name => survey.name, :survey_response_id => self.id, :error_message => error_message)
    end
    
    def synced?
      ImportHistory.exists?(:survey_id => survey.id, :survey_response_id => self.id)
    end
    
    def salesforce_object object_mapping
      sf_object = Salesforce::ObjectFactory.create(object_mapping.sf_object_type)
      object_mapping.field_mappings.each do |field_mapping|
        sf_object[field_mapping.field_name] = self[field_mapping.question_name]
      end
      sf_object      
    end
  
  end
end