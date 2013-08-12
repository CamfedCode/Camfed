require "spec_helper"

describe EpiSurveyor::Survey do
  
  it {should have_many :object_mappings}
  it {should have_many :import_histories}
    
  describe 'sync_with_epi_surveyor' do
    it "should pass expected account parameters" do
      body = {:username => Configuration.instance.epi_surveyor_user, 
              :accesstoken => Configuration.instance.epi_surveyor_token}
      headers = {"Content-Type"=>"application/x-www-form-urlencoded"}
      EpiSurveyor::Survey.should_receive(:post).with("/api/surveys", :body => body, :headers => headers)
      EpiSurveyor::Survey.sync_with_epi_surveyor
    end    
    
    it "should save the survey" do
      EpiSurveyor::Survey.stub!(:post).and_return({"Surveys" => {"Survey" => [{"SurveyId" => 1, "SurveyName" => "survey_one"}]}})
      EpiSurveyor::Survey.sync_with_epi_surveyor
      EpiSurveyor::Survey.all.should have(1).things
      EpiSurveyor::Survey.find(1).name.should == "survey_one"
    end

    it 'should return [] when no surveys found' do
      EpiSurveyor::Survey.stub!(:post).and_return(nil)
      EpiSurveyor::Survey.sync_with_epi_surveyor.should == []
    end

    it 'should return [] when list is nil' do
      EpiSurveyor::Survey.stub!(:post).and_return({"Surveys" => nil })
      EpiSurveyor::Survey.sync_with_epi_surveyor.should == []
    end

    it 'should return [] when element is nil' do
      EpiSurveyor::Survey.stub!(:post).and_return({"Surveys" => {"Survey" => nil}})
      EpiSurveyor::Survey.sync_with_epi_surveyor.should == []
    end

    it 'should destroy surveys that have been deleted' do
      old_survey = stub 'old_survey', id: 4
      existing_survey = stub 'existing_survey', id: 5
      EpiSurveyor::Survey.stub(:find_each).and_yield(old_survey).and_yield(existing_survey)
      EpiSurveyor::Survey.stub!(:post).and_return({
        "Surveys" => {
          "Survey" => [{"SurveyId" => 5, "SurveyName" => "existing_survey"}]
        }
      })
      old_survey.should_receive(:destroy)
      EpiSurveyor::Survey.sync_with_epi_surveyor
    end
  end

  describe 'responses' do
    before(:each) do
      @survey = EpiSurveyor::Survey.new
      @survey.id = 1
    end
    
    it "should call find_all_by_survey_id if not initalized" do
      EpiSurveyor::SurveyResponse.should_receive(:find_all_by_survey).with(@survey).and_return([])
      @survey.responses.should == []
    end
    
    it "should call find_all_by_survey_id only once" do
      EpiSurveyor::SurveyResponse.should_receive(:find_all_by_survey).with(@survey).and_return([])
      @survey.responses
      @survey.responses
    end
  end
  
  describe 'questions' do
    before(:each) do
      @survey = EpiSurveyor::Survey.new
      @survey.id = 1
    end
    
    it "should call find_all_by_survey_id if not initalized" do
      EpiSurveyor::Question.should_receive(:find_all_by_survey).with(@survey).and_return([])
      @survey.questions.should == []
    end
    
    it "should call find_all_by_survey_id only once" do
      EpiSurveyor::Question.should_receive(:find_all_by_survey).with(@survey).and_return([])
      @survey.questions
      @survey.questions
    end
    
  end
  
  describe 'sync!' do
    it 'should return [] if no object mapping attached' do
      EpiSurveyor::Survey.new.sync!.should == []
    end
    
    it 'should continue syncing records even if some hit exceptions' do
      response_a = EpiSurveyor::SurveyResponse.new
      response_b = EpiSurveyor::SurveyResponse.new
      survey = EpiSurveyor::Survey.new
      mappings = [ObjectMapping.new]
      survey.should_receive(:object_mappings).and_return(mappings)
      responses = [response_a, response_b]
      
      survey.should_receive(:responses).and_return(responses)
      response_a.should_receive(:sync!).with(mappings).and_raise('sync failed')
      response_b.should_receive(:sync!).with(mappings).and_return(ImportHistory.new)
      import_histories = survey.sync!
      import_histories.should have(2).things
      import_histories.first.is_a?(ImportHistory).should be true
      import_histories.last.is_a?(ImportHistory).should be true      
      
    end
    
    it 'should call sync! of its responses' do
      response_a = EpiSurveyor::SurveyResponse.new
      response_b = EpiSurveyor::SurveyResponse.new
      survey = EpiSurveyor::Survey.new
      mappings = [ObjectMapping.new]
      survey.should_receive(:object_mappings).and_return(mappings)
      responses = [response_a, response_b]
      
      survey.should_receive(:responses).and_return(responses)
      responses.each{|response| response.should_receive(:sync!).with(mappings).and_return(ImportHistory.new)}
      import_histories = survey.sync!
      import_histories.should have(2).things
      import_histories.first.is_a?(ImportHistory).should be true
      import_histories.last.is_a?(ImportHistory).should be true      
    end
  end
  
  describe 'clone_mappings_from' do
    it 'should call deep_clone on the other surveys mappings and save!' do
      other_survey = EpiSurveyor::Survey.new
      
      
      
      object_mappings = [ObjectMapping.new, ObjectMapping.new]
      object_mappings.each{|object_mapping| object_mapping.should_receive(:deep_clone).and_return(object_mapping)}
      
      other_survey.object_mappings = object_mappings
      
      survey = EpiSurveyor::Survey.new
      object_mapping = ObjectMapping.new
      survey.object_mappings << object_mapping
      
      survey.should_receive(:missing_questions).with(other_survey).and_return([])      
            
      survey.should_receive(:save!)
      
      survey.clone_mappings_from! other_survey
      
      survey.object_mappings.should have(2).things
      #it should clear the existing mappings
      survey.object_mappings.include?(object_mapping).should be false
    end
    
    
    it 'should raise MappingCloneException if there are missing questions' do
      survey = EpiSurveyor::Survey.new
      source_survey = EpiSurveyor::Survey.new
      survey.should_receive(:missing_questions).with(source_survey).and_return(['a_question'])      
      lambda { survey.clone_mappings_from!(source_survey) }.should raise_error(MappingCloneException)      
    end
  end
  
  describe 'missing_questions' do
    it 'should return the missing questions' do
      survey = EpiSurveyor::Survey.new
      survey.should_receive(:questions).and_return([])
      
      other_survey = EpiSurveyor::Survey.new
      other_survey.object_mappings << ObjectMapping.new
      other_survey.object_mappings.first.field_mappings << FieldMapping.new(:question_name => 'a_question')
      
      survey.missing_questions(other_survey).should == ['a_question']
    end
  end
  
  describe 'sync_and_notify!' do
    it 'should call sync! on all surveys and notify on all sync histories' do
      import_history = ImportHistory.new(:id =>1, :created_at => "2011/07/20", :survey_id => "12515",
                                                 :updated_at => "2012/02/22" ,:sync_errors => [SyncError.new(:id => 21)])
      import_histories = [import_history, import_history]
      surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      surveys.each do |survey| 
        survey.should_receive(:sync!).and_return([import_history])
        survey.notification_email = 'gh0123456789@example.com'
      end
      EpiSurveyor::Survey.stub(:find_each).and_yield(surveys[0]).and_yield(surveys[1])
      sync_email = ''
      Notifier.should_receive(:sync_email).with(import_histories, "gh0123456789@example.com").and_return(sync_email)
      sync_email.should_receive(:deliver)

      EpiSurveyor::Survey.should_receive(:send_sms).with("233123456789",import_histories)

      EpiSurveyor::Survey.sync_and_notify!.should == import_histories
    end

    it 'should call sync! on all surveys and notify on all sync histories to their configured emails' do
      import_history = ImportHistory.new(:id =>1, :created_at => "2011/07/20", :survey_id => "12515",
                                                 :updated_at => "2012/02/22" ,:sync_errors => [SyncError.new(:id => 21)])
      import_histories = [import_history, import_history]

      survey_1 = EpiSurveyor::Survey.new
      survey_2 = EpiSurveyor::Survey.new
      survey_1.notification_email = 'gh0123456789@example.com'
      survey_2.notification_email = 'gh0987654321@example.com'
      
      surveys = [survey_1, survey_2]
      surveys.each do |survey| 
        survey.should_receive(:sync!).and_return([import_history])
      end
      
      EpiSurveyor::Survey.stub(:find_each).and_yield(survey_1).and_yield(survey_2)
      sync_email_1 = ''
      sync_email_2 = ''      
      Notifier.should_receive(:sync_email).with([import_history], "gh0123456789@example.com").and_return(sync_email_1)
      Notifier.should_receive(:sync_email).with([import_history], "gh0987654321@example.com").and_return(sync_email_2)
      sync_email_1.should_receive(:deliver)
      sync_email_2.should_receive(:deliver)      
      EpiSurveyor::Survey.should_receive(:send_sms).exactly(2).times

      EpiSurveyor::Survey.sync_and_notify!.should == import_histories
    end
  end

  describe 'send sms for sync_and_notify' do

    def create_mock_twilio_message
      mock_client = ""
      mock_account = ""
      mock_sms = ""
      mock_messages = ""
      Twilio::REST::Client.should_receive(:new).and_return(mock_client)
      mock_client.should_receive(:account).and_return(mock_account)
      mock_account.should_receive(:sms).and_return(mock_sms)
      mock_sms.should_receive(:messages).and_return(mock_messages)
      mock_messages
    end

    it "should extract phone number from email" do
      EpiSurveyor::Survey.extract_mobile_number("gh0542208979@gmail.com<").should == "233542208979"
    end

    it "should not throw error for invalid email ids" do
      EpiSurveyor::Survey.extract_mobile_number("abcde1!@$ads@gmail.com<").should be_nil
    end

    it "should fail and log the sms response if error occurs while trying to send sms" do
      import_histories = import_histories_mock_data
      mobile_number = "233542208979"
      message = "Import Summary. Total surveys imported:3. Success:1. Incomplete:0. Failed:2"
      from_number = TWILIO_CONFIG[Rails.env]["from_number"]
      mock_twilio_message = create_mock_twilio_message()
      expected_error_message = "Some exception occurred"
      mock_twilio_message.should_receive(:create).with({:from => from_number, :to => mobile_number, :body => message}).and_raise(expected_error_message)

      EpiSurveyor::Survey.send_sms(mobile_number,import_histories)

      sms_response = SmsResponse.where(:sms_id => "invalid").first
      sms_response.message_body.should == "Error {Some exception occurred} while sending message {#{message}}"
      sms_response.sent_to.should == mobile_number
    end

    it "should be able to send sms with import histories" do
      import_histories = import_histories_mock_data
      mobile_number = "233542208979"
      message = "Import Summary. Total surveys imported:3. Success:1. Incomplete:0. Failed:2"
      from_number = TWILIO_CONFIG[Rails.env]["from_number"]
      mock_twilio_message = create_mock_twilio_message()
      mock_response = ""
      mock_response.stub(:sms_id) {"valid test sms id"}
      mock_response.stub(:date_sent) {"some date"}
      mock_response.stub(:message_body) {"test message body"}
      mock_response.stub(:sent_to) {"to number"}
      mock_response.stub(:price) {"some price"}
      mock_twilio_message.should_receive(:create).with({:from => from_number, :to => mobile_number, :body => message}).and_return(mock_response)

      EpiSurveyor::Survey.send_sms(mobile_number,import_histories)

      sms_response = SmsResponse.where(:sms_id => "valid test sms id").first
      sms_response.should_not be_nil
      sms_response.date_sent.should == "some date"
      sms_response.message_body.should == "test message body"
      sms_response.sent_to.should == "to number"
      sms_response.price.should == "some price"
    end
  end

  describe 'delete_old_surveys' do
    it 'should delete surveys with mapping > 3 years' do
    surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      surveys.each do |survey|
        survey.name = 'test'
        survey.mapping_last_modified_at = 5.years.ago
        survey.save
      end

      new_survey = EpiSurveyor::Survey.new
      new_survey.name = 'new_survey'
      new_survey.mapping_last_modified_at = Time.now
      new_survey.save
      EpiSurveyor::Survey.delete_old_surveys(3)
      EpiSurveyor::Survey.count.should == 1
    end
  end

  describe "unmapped_questions" do
    it "should return all questions list if object_mapping is not present" do
      survey = EpiSurveyor::Survey.new
      questions = [EpiSurveyor::Question.new, EpiSurveyor::Question.new]
      survey.should_receive(:questions).and_return(questions)

      survey.unmapped_questions.should == questions
    end

    it "should exclude questions which are mapped directly as questions" do
      survey = EpiSurveyor::Survey.new
      question1 = EpiSurveyor::Question.new
      question1.name = 'question1'
      question2 = EpiSurveyor::Question.new
      question2.name = 'question2'
      survey.object_mappings << ObjectMapping.new
      survey.object_mappings.first.field_mappings << FieldMapping.new(:question_name => 'question2')
      survey.should_receive(:questions).and_return([question1, question2])

      result = survey.unmapped_questions

      result.size.should == 1
      result.first.name.should == 'question1'
    end

    it "should exclude questions which are mapped through lookup_condition" do
      survey = EpiSurveyor::Survey.new
      question1 = EpiSurveyor::Question.new
      question1.name = 'question1'
      question2 = EpiSurveyor::Question.new
      question2.name = 'question2'
      survey.object_mappings << ObjectMapping.new
      survey.object_mappings.first.field_mappings << FieldMapping.new(:lookup_condition => "School WHERE District__c='a1AT0000000x5UL' AND Name=<question2>")
      survey.should_receive(:questions).and_return([question1, question2])

      result = survey.unmapped_questions

      result.size.should == 1
      result.first.name.should == 'question1'
    end
  end

  describe "update_mapping_status" do
    it "should update mapping status as Unmapped if all questions are unmapped" do
      survey = EpiSurveyor::Survey.create
      questions = [EpiSurveyor::Question.new, EpiSurveyor::Question.new]
      survey.should_receive(:questions).and_return(questions)
      survey.should_receive(:unmapped_questions).and_return(questions)

      survey.update_mapping_status
      survey.reload
      survey.mapping_status.should == EpiSurveyor::Survey::MAPPING_STATUS::UNMAPPED
    end

    it "should update mapping status as Unmapped if some questions are mapped" do
      survey = EpiSurveyor::Survey.create
      question1 = EpiSurveyor::Question.new
      question2 = EpiSurveyor::Question.new
      survey.should_receive(:questions).and_return([question1, question2])
      survey.should_receive(:unmapped_questions).and_return([question2])

      survey.update_mapping_status
      survey.reload
      survey.mapping_status.should == EpiSurveyor::Survey::MAPPING_STATUS::PARTIAL
    end

    it "should update not update mapping status if mapping_status is Mapped" do
      survey = EpiSurveyor::Survey.create(:mapping_status => EpiSurveyor::Survey::MAPPING_STATUS::MAPPED)

      survey.update_mapping_status
      survey.reload
      survey.mapping_status.should == EpiSurveyor::Survey::MAPPING_STATUS::MAPPED
    end
  end

  describe "having_mapping_status" do
    before :each do
      @survey1 = EpiSurveyor::Survey.create(:mapping_status => EpiSurveyor::Survey::MAPPING_STATUS::MAPPED)
      @survey2 = EpiSurveyor::Survey.create(:mapping_status => EpiSurveyor::Survey::MAPPING_STATUS::UNMAPPED)
    end

    it "should return all records if having_mapping_status is scoped but no mapping_status is requested" do
      surveys = EpiSurveyor::Survey.having_mapping_status(nil)
      surveys.size.should == 2
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_true
    end

    it "should return records with requested mapping_status" do
      surveys = EpiSurveyor::Survey.having_mapping_status(EpiSurveyor::Survey::MAPPING_STATUS::MAPPED)
      surveys.size.should == 1
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_false
    end
  end

  describe "modified_between" do
    before :each do
      @survey1 = EpiSurveyor::Survey.create
      @survey2 = EpiSurveyor::Survey.create
      @survey1.update_attribute(:mapping_last_modified_at, Time.now - 2.days)
      @survey2.update_attribute(:mapping_last_modified_at, Time.now - 1.days)
    end

    it "should return all records if modified_between is scoped but no start_date, end_date is requested" do
      surveys = EpiSurveyor::Survey.modified_between(nil,'')
      surveys.size.should == 2
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_true
    end

    it "should return all records if modified_between is scoped and start_date is provided but no end_date is requested" do
      surveys = EpiSurveyor::Survey.modified_between(Date.today - 2.days, nil)
      surveys.size.should == 2
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_true
    end

    it "should return records within requested dates" do
      surveys = EpiSurveyor::Survey.modified_between(Date.today - 3.days, Date.today - 2.days)
      surveys.size.should == 1
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_false
    end
  end

  describe "starting_with" do
    before :each do
      @survey1 = EpiSurveyor::Survey.create
      @survey2 = EpiSurveyor::Survey.create
      @survey1.update_attribute(:name, 'Abc')
      @survey2.update_attribute(:name, 'Def')
    end

    it "should return all records if starting_with is scoped but start_with is requested" do
      surveys = EpiSurveyor::Survey.starting_with(nil)
      surveys.size.should == 2
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_true
    end

    it "should return records with requested start_with" do
      surveys = EpiSurveyor::Survey.starting_with('A')
      surveys.size.should == 1
      surveys.include?(@survey1).should be_true
      surveys.include?(@survey2).should be_false
    end
  end

  private
  def import_histories_mock_data
    import_histories = []
    import_histories << ImportHistory.new(:id =>1, :created_at => "2011/07/20", :survey_id => "12515",
                                           :updated_at => "2012/02/22" ,:sync_errors => [SyncError.new(:id => 21)])
    import_histories << ImportHistory.new(:id =>2, :created_at => "2011/07/20", :survey_id => "12515",
                                           :updated_at => "2012/03/22", :sync_errors => [SyncError.new(:id => 22)])
    import_histories << ImportHistory.new(:id =>3, :created_at => "2011/07/20",:survey_id => "12515",
                                           :updated_at => "2012/02/22")
  end

end