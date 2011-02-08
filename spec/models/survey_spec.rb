require "spec_helper"

describe Survey do
  
  describe 'init' do
    it 'should set auth' do
      expected_auth = { :username => 'Camfedtest@gmail.com', :accesstoken => 'YUc8UfyeOm3W9GqNSJYs' }
      assert_equal(expected_auth, Survey.auth)
    end
  
    it 'should set headers' do
      expected_headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
      assert_equal(expected_headers, Survey.headers)
    end
  end
  
  describe 'all' do
    it "should pass expected account parameters" do
      body = {:username=>"Camfedtest@gmail.com", :accesstoken=>"YUc8UfyeOm3W9GqNSJYs"}
      headers = {"Content-Type"=>"application/x-www-form-urlencoded"}
      Survey.should_receive(:post).with("/api/surveys", :body => body, :headers => headers)
      Survey.all
    end    
  end
  
  describe 'find_by_name' do
    it 'should find survey by name when it exists' do
      Survey.stub!(:all).and_return({"Surveys" => {"Survey" => [{"SurveyId" => 1, "SurveyName" => "the_name"}]}})
      the_survey = Survey.find_by_name "the_name"
    
      the_survey.id.should == 1
      the_survey.name.should == "the_name"
    end
  
    it 'should return nil when survey not found' do
      Survey.stub!(:all).and_return({"Surveys" => {"Survey" => [{"SurveyId" => 1, "SurveyName" => "the_name"}]}})
      the_survey = Survey.find_by_name "the_name2"
    
      the_survey.should == nil
    end
  
    it 'should return nil when no surveys found' do
      Survey.stub!(:all).and_return(nil)
      the_survey = Survey.find_by_name "the_name"
    
      the_survey.should == nil
    end  
    
    it 'should return nil when list is nil' do
      Survey.stub!(:all).and_return({"Surveys" => nil })
      the_survey = Survey.find_by_name "the_name"
    
      the_survey.should == nil
    end
    
    it 'should return nil when element is nil' do
      Survey.stub!(:all).and_return({"Surveys" => {"Survey" => nil}})
      the_survey = Survey.find_by_name "the_name"
    
      the_survey.should == nil
    end
  end
  
  describe 'responses' do
    it "should call find_all_by_survey_id if not initalized" do
      SurveyResponse.should_receive(:find_all_by_survey_id).with(1).and_return([])
      survey = Survey.new
      survey.id = 1
      survey.responses.should == []
    end
    
    it "should call find_all_by_survey_id only once" do
      SurveyResponse.should_receive(:find_all_by_survey_id).with(1).and_return([])
      survey = Survey.new
      survey.id = 1
      survey.responses
      survey.responses
    end
  end
  
end