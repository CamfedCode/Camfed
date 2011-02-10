require "spec_helper"

describe EpiSurveyor::Survey do
  
  it {should have_many :object_mappings}
  it {should have_many :import_histories}
  
  describe 'init' do
    it 'should set auth' do
      expected_auth = { :username => 'Camfedtest@gmail.com', :accesstoken => 'YUc8UfyeOm3W9GqNSJYs' }
      assert_equal(expected_auth, EpiSurveyor::Survey.auth)
    end
  
    it 'should set headers' do
      expected_headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
      assert_equal(expected_headers, EpiSurveyor::Survey.headers)
    end
  end
  
  describe 'sync_with_epi_surveyor' do
    it "should pass expected account parameters" do
      body = {:username=>"Camfedtest@gmail.com", :accesstoken=>"YUc8UfyeOm3W9GqNSJYs"}
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
      responses.each{|response| response.should_receive(:sync!).with(mappings)}
      survey.sync!
    end
  end
  
  
end