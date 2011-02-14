require 'spec_helper'
require 'controllers/authentication_helper'

describe QuestionsController do
  
  before(:each) do
    sign_on
  end

  describe "GET 'index'" do
    it "should be successful" do
      survey = EpiSurveyor::Survey.new
      EpiSurveyor::Survey.should_receive(:find).with("1").and_return(survey)
      survey.should_receive(:questions).and_return([])
      
      get 'index', :survey_id => "1"
      
      response.should be_success
      assigns[:questions].should == []
      assigns[:survey].should == survey
    end
    
    it 'should redirect to surveys with a flash error if there is an error in fetching' do
      survey = EpiSurveyor::Survey.new(:id => 1)
      EpiSurveyor::Survey.should_receive(:find).with("1").and_return(survey)
      survey.should_receive(:questions).and_raise('no connection error')
      
      get 'index', :survey_id => "1"
      flash[:error].should == 'Could not fetch questions from EpiSurveyor because of no connection error'
      response.should redirect_to surveys_path
    end
  end

end
