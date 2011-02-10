require "spec_helper"

describe EpiSurveyor::Survey do
  
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
  
  describe 'all' do
    it "should pass expected account parameters" do
      body = {:username=>"Camfedtest@gmail.com", :accesstoken=>"YUc8UfyeOm3W9GqNSJYs"}
      headers = {"Content-Type"=>"application/x-www-form-urlencoded"}
      EpiSurveyor::Survey.should_receive(:post).with("/api/surveys", :body => body, :headers => headers)
      EpiSurveyor::Survey.all
    end    
    
    
    it 'should return [] when no surveys found' do
      EpiSurveyor::Survey.stub!(:post).and_return(nil)
      EpiSurveyor::Survey.all.should == []
    end  
    
    it 'should return [] when list is nil' do
      EpiSurveyor::Survey.stub!(:post).and_return({"Surveys" => nil })
      EpiSurveyor::Survey.all.should == []
    end
    
    it 'should return [] when element is nil' do
      EpiSurveyor::Survey.stub!(:post).and_return({"Surveys" => {"Survey" => nil}})
      EpiSurveyor::Survey.all.should == []
    end
    
  end
  
  describe 'find_by_name' do
    it 'should find survey by name when it exists' do
      survey = EpiSurveyor::Survey.new
      survey.id = 1
      survey.name = 'the_name'

      EpiSurveyor::Survey.should_receive(:all).and_return([survey])
      the_survey = EpiSurveyor::Survey.find_by_name "the_name"
    
      the_survey.id.should == 1
      the_survey.name.should == "the_name"
    end
    
    it 'should return nil when its not found' do
      EpiSurveyor::Survey.should_receive(:all).and_return([])
      EpiSurveyor::Survey.find_by_name("the_name").should be nil
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
      mapping = {}
      survey.should_receive(:mapping).and_return(mapping)
      responses = [response_a, response_b]
      
      survey.should_receive(:responses).and_return(responses)
      responses.each{|response| response.should_receive(:sync!).with(mapping)}
      survey.sync!
    end
  end
  
  
end