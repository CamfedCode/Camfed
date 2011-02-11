module EpiSurveyor
  class Survey < ActiveRecord::Base
    include HTTParty
    base_uri 'https://www.episurveyor.org'

    has_many :object_mappings
    has_many :import_histories

    attr_accessible :id
    attr_accessor :responses
  
    def test
      Survey.find_by_name('MV-Dist-Info5').sync!
    end
    
    def responses
      @responses ||= SurveyResponse.find_all_by_survey(self)
    end
    
    def questions
      @questions ||= Question.find_all_by_survey(self)
    end
    
    def self.auth
      @@auth ||= {:username => 'Camfedtest@gmail.com', :accesstoken => 'YUc8UfyeOm3W9GqNSJYs'}
    end

    def self.headers
      @@headers ||= {'Content-Type' => 'application/x-www-form-urlencoded'}
    end
  
    def self.sync_with_epi_surveyor
      response = post('/api/surveys', :body => auth, :headers => headers)
      return [] if response.nil? || response['Surveys'].nil? || response['Surveys']['Survey'].nil?

      surveys = []
      raw_surveys = response['Surveys']['Survey']
      raw_surveys.each do |survey_hash|
        survey = Survey.new
        survey.id = survey_hash['SurveyId']
        survey.name = survey_hash['SurveyName']
        survey.save! unless Survey.exists?(:id => survey.id)
        surveys << survey
      end
      surveys
    end
  
    def sync!
      mappings = object_mappings
      responses.collect {|response| response.sync!(mappings)}.select{|import_history| import_history.present?}
    end

  end
end