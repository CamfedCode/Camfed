module EpiSurveyor
  class Survey < ActiveRecord::Base
    include HTTParty
    base_uri Configuration.instance.epi_surveyor_url
    extend EpiSurveyor::Dependencies::ClassMethods

    self.per_page = 20
    has_many :object_mappings, :dependent => :destroy
    has_many :import_histories, :dependent => :destroy

    attr_accessible :id, :notification_email, :mapping_status
    attr_accessor :responses

    scope :ordered, order('name ASC')

    scope :page, lambda { |page| paginate(:page => page) }

    scope :modified_between, lambda { |start_date, end_date| where("surveys.mapping_last_modified_at between ? AND ?", start_date, end_date)}

    scope :starting_with, lambda { |starting_char| where("UPPER(surveys.name) like ?", starting_char + '%') }

    module MAPPING_STATUS
      MAPPED = 'Mapped'
      PARTIAL = 'Partial'
      UNMAPPED = 'Unmapped'
      ALL = [MAPPED, PARTIAL, UNMAPPED]
    end

    def find_potential_list_of_target_surveys_for_cloning_mappings_into
      Survey.all.reject{|survey| survey == self}.sort_by(&:name)
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

      Survey.all.each do |survey|
        survey.destroy unless surveys.any? {|s| s.id == survey.id }
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
      end

      all_histories
    end

    def self.delete_old_surveys mapping_last_modified_at
      # querying Survey to get mappings last modified > n years and delete them
      surveys = EpiSurveyor::Survey.where("mapping_last_modified_at < ?", (mapping_last_modified_at.years.ago).utc)
      surveys.all.each do |survey|
        survey.destroy
      end  

    end

    def update_mapping_status
      update_attributes!(:mapping_status => ((unmapped_questions.count == questions.count) ? MAPPING_STATUS::UNMAPPED : MAPPING_STATUS::PARTIAL)) if mapping_status != MAPPING_STATUS::MAPPED
    end

    def unmapped_questions
      return questions unless object_mappings.present?
      questions.reject do |question|
        filed_mappings = object_mappings.collect(&:field_mappings).flatten
        filed_mappings.collect(&:question_name).index{ |x| x =~/#{question.name}/ }.present? || filed_mappings.collect(&:lookup_condition).index{ |x| x =~/<#{question.name}>/ }.present?
      end
    end

  end

end