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
    
    it "should get all surveys whose mapping was modified between the specified start and end dates" do
      surveys = []
      start_date = "2011/07/01"
      end_date = "2011/07/15".to_time.advance(:days => 1).to_date
      EpiSurveyor::Survey.should_receive(:where).with("surveys.mapping_last_modified_at between ? AND ?", start_date, end_date).and_return([])
      get 'index', :start_date => '2011/07/01', :end_date => '2011/07/15'     
      response.should be_success
      assigns[:surveys].should == surveys
    end
    
    it "should get all surveys if only the start date is specified for the mapping last modified date filter" do
      surveys = []
      EpiSurveyor::Survey.should_receive(:all).and_return(surveys)
      get 'index', :start_date => '2011/07/01', :end_date => ""    
      response.should be_success
      assigns[:surveys].should == surveys
    end
  end
  
  describe "GET 'edit'" do
    it "should get a survey" do
      survey = EpiSurveyor::Survey.new
      EpiSurveyor::Survey.should_receive(:find).with(1).and_return(survey)
      get 'edit', :id => 1      
      response.should be_success
      assigns[:survey].should == survey      
    end
    
  end

  describe "PUT 'update'" do
    it "should update a survey" do
      survey = EpiSurveyor::Survey.new
      EpiSurveyor::Survey.should_receive(:find).with(1).and_return(survey)
      put 'update', :id => 1, :epi_surveyor_survey => {:notification_email => 'hello@example.com'}
      assigns[:survey].notification_email.should == 'hello@example.com'      
      response.should redirect_to root_path
    end
    
  end
  
  
  describe 'after select many' do
    before(:each) do
      @surveys = [EpiSurveyor::Survey.new, EpiSurveyor::Survey.new]
      EpiSurveyor::Survey.should_receive(:find).with([1,2]).and_return(@surveys)
    end
    
    describe 'POST import_selected' do
      it "should find the surveys by ids and then sync" do
        @surveys.each {|survey| survey.should_receive(:sync!).and_return(ImportHistory.new)}
        post 'import_selected', :survey_ids => [1, 2]
        response.should redirect_to surveys_path
        assigns[:surveys].should == @surveys
      end
    end
    
    describe 'DELETE destroy_selected' do
      it 'should delete all selected surveys' do
        @surveys.each {|survey| survey.should_receive(:destroy) }
        delete 'destroy_selected', :survey_ids => [1, 2]
        response.should redirect_to surveys_path
        assigns[:surveys].should == @surveys
      end
    end
    
  end
  
  describe 'Get Search' do
    it 'should render index with @surveys' do
      EpiSurveyor::Survey.should_receive(:where).with("LOWER(surveys.name) LIKE ?", "%query%").and_return([])
      get 'search', :query => 'QUERY'
      response.should render_template :index
      assigns[:surveys].should == []
    end
  end
end
