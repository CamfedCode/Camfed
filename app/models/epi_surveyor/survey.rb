module EpiSurveyor
  class Survey < ActiveRecord::Base
    include HTTParty
    base_uri Configuration.instance.epi_surveyor_url    
    extend EpiSurveyor::Dependencies::ClassMethods

    has_many :object_mappings, :dependent => :destroy    
    has_many :import_histories, :dependent => :destroy
    
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
      import_histories = responses.collect {|response| response.sync!(mappings)}.select{|import_history| import_history.present?}
      touch(:last_imported_at)
      import_histories
    end
    
    def clone_mappings_from! other_survey
      missing_questions = missing_questions(other_survey)
      logger.debug "MISSING Q=#{missing_questions}"
      raise MappingCloneException.new(missing_questions) if missing_questions.present?

      object_mappings.clear
      other_survey.object_mappings.each do |object_mapping|
        object_mappings << object_mapping.deep_clone
      end
      save!
    end
    
    def missing_questions other_survey
      question_names = questions.map(&:name)
      missing_ones = []
      other_survey.object_mappings.each do |object_mapping|
        object_mapping.field_mappings.each do |field_mapping| 
          if field_mapping.question_name.present? && question_names.exclude?(field_mapping.question_name)
            missing_ones << field_mapping.question_name
          end
        end
      end
      missing_ones
    end
    
    
  end
end