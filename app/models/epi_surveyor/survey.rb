module EpiSurveyor
  class Survey < ActiveRecord::Base
    COUNTRY_CODES = {"gh" => "233"}
    include HTTParty
    base_uri Configuration.instance.epi_surveyor_url
    extend EpiSurveyor::Dependencies::ClassMethods

    has_many :object_mappings, :dependent => :destroy
    has_many :import_histories, :dependent => :destroy

    attr_accessible :id, :notification_email
    attr_accessor :responses

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

      Survey.all.each do |survey|
        survey.destroy unless surveys.any? {|s| s.id == survey.id}
      end

      surveys
    end

    def sync!
      mappings = object_mappings
      return [] if mappings.blank?
      import_histories = []

      responses.each do |response|
        begin
          import_history = response.sync!(mappings)
          import_histories << import_history if import_history.present?
        rescue Exception => error
          import_history = ImportHistory.new(:survey_id => self.id, :survey_response_id => response.id)
          sync_error = SyncError.new(:raw_request => response.inspect,
            :raw_response => error.message,
            :salesforce_object => "")
          
          import_history.sync_errors << sync_error
          import_histories << import_history
          logger.error "Could not sync because of #{error.message} #{error.backtrace.join}"
          
        end
      end
      
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
    
    def self.sync_and_notify!
      all_histories = []
      recipient_histories = {}
      
      all.each do |survey|
        sync_results = survey.sync!
        all_histories += sync_results
        recipient_histories[survey.notification_email] ||= []
        recipient_histories[survey.notification_email] += sync_results
      end
      
      recipient_histories.each_pair do |to_email, histories|
        Notifier.sync_email(histories, to_email).deliver unless to_email.blank?
        send_sms(extract_mobile_number(to_email),histories)
      end

      all_histories
    end

    def self.extract_mobile_number(email)
      if  /[a-z]{2}\d{1,10}{10}@/=~ email
        code = COUNTRY_CODES[email.slice(0..1)]
        phone_number = code + email.slice(3..11)
      end
    end

    def self.send_sms(mobile_number,histories)
      begin
        message = "Import Summary. Total surveys imported:#{histories.length}. Success:#{histories.count {|history| history.status=='Success'}}. Incomplete:#{histories.count {|history| history.status=='Incomplete'}}. Failed:#{histories.count {|history| history.status=='Failed'}}"
        sms = Moonshado::Sms.new(mobile_number, message)
        sms_delivery = sms.deliver_sms
        sms_response = SmsResponse.new(:sms_id => sms_delivery.delete(:id), :properties => sms_delivery)
        sms_response.save
      rescue Exception => error
        properties = {:error => error.message, :mobile_number => mobile_number}
        sms_response = SmsResponse.new(:sms_id => "invalid", :properties => properties)
        sms_response.save
        logger.error "Sending SMS failed with error #{error}"
      end
      end
    end
  end
