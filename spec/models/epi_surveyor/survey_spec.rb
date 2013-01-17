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
      surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      surveys.each do |survey| 
        survey.should_receive(:sync!).and_return([1])
        survey.notification_email = 'admin@example.com'
      end
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      sync_email = ''
      Notifier.should_receive(:sync_email).with([1, 1], "admin@example.com").and_return(sync_email)
      sync_email.should_receive(:deliver)
      EpiSurveyor::Survey.sync_and_notify!.should == [1, 1]
    end

    it 'should call sync! on all surveys and notify on all sync histories to their configured emails' do
      survey_1 = EpiSurveyor::Survey.new
      survey_2 = EpiSurveyor::Survey.new
      survey_1.notification_email = 'survey1@example.com'
      survey_2.notification_email = 'survey2@example.com'
      
      surveys = [survey_1, survey_2]
      surveys.each do |survey| 
        survey.should_receive(:sync!).and_return([1])
      end
      
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      sync_email_1 = ''
      sync_email_2 = ''      
      Notifier.should_receive(:sync_email).with([1], "survey1@example.com").and_return(sync_email_1)
      Notifier.should_receive(:sync_email).with([1], "survey2@example.com").and_return(sync_email_2)      
      sync_email_1.should_receive(:deliver)
      sync_email_2.should_receive(:deliver)      
      EpiSurveyor::Survey.sync_and_notify!.should == [1, 1]
    end
  end

  describe 'delete_old_surveys' do
    it 'should delete surveys with mapping > 3 years' do
    surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      surveys.each do |survey| 
        survey.name = 'test'
        survey.mapping_last_modified_at = 5.years.ago
        survey.save
        p "param value in 1: #{survey.name}"
        p "param value in 1: #{survey.mapping_last_modified_at}"
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
  
end