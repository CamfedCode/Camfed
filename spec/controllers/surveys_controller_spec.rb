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
  
  describe 'Get Search' do
    it 'should render index with @surveys' do
      EpiSurveyor::Survey.should_receive(:where).with("surveys.name LIKE ?", "%QUERY%").and_return([])
      get 'search', :query => 'QUERY'
      response.should render_template :index
      assigns[:surveys].should == []
    end
  end
end
