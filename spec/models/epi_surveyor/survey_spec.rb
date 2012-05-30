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
      EpiSurveyor::Survey.should_receive(:all).and_return [old_survey, existing_survey]
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
        survey.notification_email = 'admin@example.com'
      end
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      sync_email = ''
      Notifier.should_receive(:sync_email).with(import_histories, "admin@example.com").and_return(sync_email)
      sync_email.should_receive(:deliver)
      mock_sms = ""
      mock_sms_response = {:stat=>"ok", :id=>"e3debdc7f4719ec0", :credit => 500}
      Moonshado::Sms.should_receive(:new).and_return(mock_sms)
      mock_sms.should_receive(:deliver_sms).and_return(mock_sms_response)
      EpiSurveyor::Survey.sync_and_notify!.should == import_histories
    end

    it 'should call sync! on all surveys and notify on all sync histories to their configured emails' do
      import_history = ImportHistory.new(:id =>1, :created_at => "2011/07/20", :survey_id => "12515",
                                                 :updated_at => "2012/02/22" ,:sync_errors => [SyncError.new(:id => 21)])
      import_histories = [import_history, import_history]

      survey_1 = EpiSurveyor::Survey.new
      survey_2 = EpiSurveyor::Survey.new
      survey_1.notification_email = 'survey1@example.com'
      survey_2.notification_email = 'survey2@example.com'
      
      surveys = [survey_1, survey_2]
      surveys.each do |survey| 
        survey.should_receive(:sync!).and_return([import_history])
      end
      
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      sync_email_1 = ''
      sync_email_2 = ''      
      Notifier.should_receive(:sync_email).with([import_history], "survey1@example.com").and_return(sync_email_1)
      Notifier.should_receive(:sync_email).with([import_history], "survey2@example.com").and_return(sync_email_2)
      sync_email_1.should_receive(:deliver)
      sync_email_2.should_receive(:deliver)      
      mock_sms = ""
      mock_sms_response = {:stat=>"ok", :id=>"e3debdc7f4719ec0", :credit => 500}
      Moonshado::Sms.should_receive(:new).exactly(2).times().and_return(mock_sms)
      mock_sms.should_receive(:deliver_sms).exactly(2).times().and_return(mock_sms_response)

      EpiSurveyor::Survey.sync_and_notify!.should == import_histories
      sms_response = SmsResponse.where(:sms_id => "e3debdc7f4719ec0").first
      sms_response.properties.should == {:stat=>"ok", :credit => 500}
    end

    it "should extract phone number from email" do
      EpiSurveyor::Survey.extract_mobile_number("gh0542208979@gmail.com<").should == "233542208979"
    end

    it "should not throw error for invalid email ids" do
      EpiSurveyor::Survey.extract_mobile_number("abcde1!@$ads@gmail.com<").should be_nil
    end

    it "should fail and log the sms response if the mobile number is not valid" do
      EpiSurveyor::Survey.send_sms("invalid_mobile_number",{})
      sms_response = SmsResponse.where(:sms_id => "invalid").first
      sms_response.properties[:error].should == "Phone number (invalid_mobile_number) is not formatted correctly"
      sms_response.properties[:mobile_number].should == "invalid_mobile_number"
    end
    it "should be able to send sms" do
      import_histories = import_histories_mock_data
      mobile_number = "233542208979"
      message = "Import Summary. Total surveys imported:3. Success:1. Incomplete:0. Failed:2"
      sms_instance = ""
      Moonshado::Sms.should_receive(:new).with(mobile_number,message).and_return(sms_instance)
      sms_instance.should_receive(:deliver_sms)
      EpiSurveyor::Survey.send_sms(mobile_number,import_histories)
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