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
    before(:each) do
      @survey = EpiSurveyor::Survey.new
      @survey.name = 'a survey'
      @survey.id = 1
      EpiSurveyor::Survey.should_receive(:find).with(@survey.id).and_return(@survey)
    end
    
    it "should find the survey by id and then sync" do
      @survey.should_receive(:sync!).and_return([ImportHistory.new])
      post 'import', :id => 1
      response.should redirect_to surveys_path
      assigns[:survey].should == @survey 
    end
    
    it 'should respond with the count of errors in the import' do
      import_history = ImportHistory.new
      import_history.sync_errors << SyncError.new
      
      @survey.should_receive(:sync!).and_return([import_history])
      post 'import', :id => 1
      flash[:error].should == 'Failed to import 1 out of 1 new response(s) to a survey'
    end
    
  end
  
  describe 'POST import_selected' do
    it "should find the surveys by ids and then sync" do
      surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      EpiSurveyor::Survey.should_receive(:find).with([1,2]).and_return(surveys)

      surveys.each {|survey| survey.should_receive(:sync!).and_return(ImportHistory.new)}

      post 'import_selected', :survey_ids => [1, 2]
      
      response.should redirect_to surveys_path
      assigns[:surveys].should == surveys
    end
  end
end
