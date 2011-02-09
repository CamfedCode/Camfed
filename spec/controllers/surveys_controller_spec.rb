require 'spec_helper'

describe SurveysController do

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
      survey_name = "the_survey"
      survey = EpiSurveyor::Survey.new
      survey.name = survey_name
      EpiSurveyor::Survey.should_receive(:find_by_name).with(survey_name).and_return(survey)
      survey.should_receive(:sync!)
      
      post 'import', :id => "1", :survey_name => survey_name
      response.should redirect_to surveys_path
      assigns[:survey].should == survey 
    end
  end
end
