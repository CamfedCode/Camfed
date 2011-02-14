require 'spec_helper'
require 'controllers/authentication_helper'

describe SurveysController do
  before(:each) do
    sign_on
  end
  
  describe "GET 'index'" do
    it "should get all surveys" do
      surveys = []
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      get 'index'      
      response.should be_success
      assigns[:surveys].should == surveys
    end
  end

  describe "POST 'Import'" do
    it "should find the survey by name and then sync" do
      survey = EpiSurveyor::Survey.new
      survey.id = 1
      EpiSurveyor::Survey.should_receive(:find).with(survey.id).and_return(survey)
      survey.should_receive(:sync!)
      
      post 'import', :id => 1
      response.should redirect_to surveys_path
      assigns[:survey].should == survey 
      assigns[:survey].last_imported_at.should > 1.minutes.ago
    end
  end
end
