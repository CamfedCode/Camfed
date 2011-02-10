require 'spec_helper'

describe QuestionsController do

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
  end

end
