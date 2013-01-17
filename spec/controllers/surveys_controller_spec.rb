require 'spec_helper'
require 'controllers/authentication_helper'

describe SurveysController do
  before(:each) do
    sign_on
  end
  
  describe "GET 'index'" do
    it "should get the first page of all surveys if no page attribute is specified" do
      surveys = []
      EpiSurveyor::Survey.stub_chain(:ordered, :page).with(nil).and_return(surveys)
      get 'index'      
      response.should be_success
      assigns[:surveys].should == surveys
    end
    
    it "should get the first page of all surveys whose mapping was modified between the specified start and end dates" do
      @relation = mock(ActiveRecord::Relation)
      surveys = []
      start_date = "2011/07/01"
      end_date = "2011/07/15".to_time.advance(:days => 1).to_date
      EpiSurveyor::Survey.stub_chain(:ordered, :modified_between).with(start_date, end_date).and_return(@relation)
      @relation.should_receive(:page).with(nil).and_return(surveys)
      get 'index', :start_date => '2011/07/01', :end_date => '2011/07/15'     
      response.should be_success
      assigns[:surveys].should == surveys
    end
    
    it "should get first page of all surveys if only the start date is specified for the mapping last modified date filter" do
      surveys = []
      EpiSurveyor::Survey.stub_chain(:ordered, :page).with(nil).and_return(surveys)
      get 'index', :start_date => '2011/07/01', :end_date => ""    
      response.should be_success
      assigns[:surveys].should == surveys
    end

    it "should get the appropriate page of all surveys if page attribute is specified" do
      @page = 2
      surveys = []
      EpiSurveyor::Survey.stub_chain(:ordered, :page).with(@page).and_return(surveys)
      get 'index', :page => 2
      response.should be_success
      assigns[:surveys].should == surveys
    end

    it "should get the first page of surveys starting with the specified alphabet" do
      @relation = mock(ActiveRecord::Relation)
      surveys = []
      EpiSurveyor::Survey.stub_chain(:ordered, :starting_with).with('A').and_return(@relation)
      @relation.should_receive(:page).with(nil).and_return(surveys)
      get 'index', :start_with => 'A'
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
      @relation = mock(ActiveRecord::Relation)
      EpiSurveyor::Survey.should_receive(:where).with("LOWER(surveys.name) LIKE ?", "%query%").and_return(@relation)
      @relation.should_receive(:page).with(nil).and_return(@relation)
      @relation.should_receive(:ordered).and_return([])
      get 'search', :query => 'QUERY'
      response.should render_template :index
      assigns[:surveys].should == []
    end
  end

  describe 'update_mapping_status' do
    it 'should update mapping_status' do
      survey = EpiSurveyor::Survey.create(:id => 1)
      post 'update_mapping_status', :id => 1, :mapping_status => 'Mapped'
      survey.reload
      survey.mapping_status.should == 'Mapped'
      response.should redirect_to survey_mappings_path(survey)
    end
  end
end
