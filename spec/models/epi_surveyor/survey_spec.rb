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
    it 'should call sync! of its responses' do
      response_a = EpiSurveyor::SurveyResponse.new
      response_b = EpiSurveyor::SurveyResponse.new
      survey = EpiSurveyor::Survey.new
      mappings = []
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
  
end