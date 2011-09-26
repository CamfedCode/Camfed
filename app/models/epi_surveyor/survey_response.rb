module EpiSurveyor
  class SurveyResponse
    include HTTParty
    base_uri Configuration.instance.epi_surveyor_url    
    extend EpiSurveyor::Dependencies::ClassMethods
  
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
      body = auth.merge(:surveyid => survey.id)
      survey_data = post('/api/surveydata', :body => body, :headers => headers)
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
      
      import_history = ImportHistory.new(:survey_id => survey.id, :survey_response_id => self.id)

      object_mappings.each do |object_mapping|
        begin
          import_history.object_histories << salesforce_object(object_mapping).sync!
        rescue SyncException => sync_exception
          import_history.sync_errors << sync_exception.sync_error
        end
      end

      import_history.save!
      import_history
    end
    
    def synced?
      ImportHistory.exists?(:survey_id => survey.id, :survey_response_id => self.id)
    end
    
    def salesforce_object object_mapping
      sf_object = Salesforce::Base.where(:name => object_mapping.salesforce_object_name).first
      object_mapping.field_mappings.each do |field_mapping|
        sf_object[field_mapping.field_name] = value_for(field_mapping)
      end
      sf_object
    end
    
    def value_for field_mapping
      return field_mapping.predefined_value if field_mapping.predefined_value?
      return lookup(field_mapping) if field_mapping.lookup?      
      self[field_mapping.question_name]
    end
    
    def lookup field_mapping
      condition = replace_with_answers field_mapping.lookup_condition
      Salesforce::Base.first_from_salesforce(:Id, field_mapping.lookup_object_name, condition)
    end

    def replace_with_answers condition_string
      Rails.logger.debug("Input Condition String: #{condition_string}")

      replaced_condition_string = condition_string.gsub(/\<([^\>]+)\>/) do |match|
        formatted_answer(question_answers[$1])
      end

      Rails.logger.debug("Replaced Condition String: #{replaced_condition_string}")
      replaced_condition_string
    end
    
    #should not quote if its a date argument
    def formatted_answer answer
      y, m, d = answer.to_s.split('-')
      
      escaped_answer = answer.gsub "'", "\\\\'"
      escaped_answer = escaped_answer.gsub "`", "\\\\'"

      Date.valid_date?(y.to_i, m.to_i, d.to_i) ? answer : "'#{escaped_answer}'"
    end
  
  end
end