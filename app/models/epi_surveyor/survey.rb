module EpiSurveyor
  class Survey
    include HTTParty
    base_uri 'https://www.episurveyor.org'

    attr_accessor :id, :name, :responses
  
    def test
      Survey.find_by_name('MV-Dist-Info5').sync!
    end
    
    def responses
      @responses ||= SurveyResponse.find_all_by_survey(self)
    end

    def self.auth
      @@auth ||= {:username => 'Camfedtest@gmail.com', :accesstoken => 'YUc8UfyeOm3W9GqNSJYs'}
    end

    def self.headers
      @@headers ||= {'Content-Type' => 'application/x-www-form-urlencoded'}
    end
  
    def self.all
      response = post('/api/surveys', :body => auth, :headers => headers)
      return [] if response.nil? || response['Surveys'].nil? || response['Surveys']['Survey'].nil?

      surveys = []
      raw_surveys = response['Surveys']['Survey']
      raw_surveys.each do |survey_hash|
        survey = Survey.new
        survey.id = survey_hash['SurveyId']
        survey.name = survey_hash['SurveyName']
        surveys << survey
      end
      surveys
    end
  
    def self.find_by_name name
      all.select{|survey| survey.name == name}.first
      # all_surveys = all
      # 
      #      return nil if all_surveys.nil? || all_surveys['Surveys'].nil? || all_surveys['Surveys']['Survey'].nil?
      #      surveys = all_surveys['Surveys']['Survey']
      #      surveys.each do |survey_hash|
      #        if survey_hash['SurveyName'].present? && survey_hash['SurveyName'] == name
      #          survey = Survey.new
      #          survey.id = survey_hash['SurveyId']
      #          survey.name = survey_hash['SurveyName']
      #          return survey
      #        end
      #      end
      #    
      #      nil
    end
  
    def sync!
      field_mapping = mapping
      responses.each {|response| response.sync!(field_mapping)}
    end
  
    def mapping
      EpiSurveyorToSalesforceMapping.find(self.name)
    end

  end
end