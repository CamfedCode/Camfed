require 'spec_helper'
require 'controllers/authentication_helper'

describe ImportHistoriesController do
  before(:each) do
    sign_on
  end

  def mock_import_history(stubs={})
    @mock_import_history ||= mock_model(ImportHistory, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all import_histories as @import_histories" do
      survey = ''
      survey.should_receive(:import_histories).and_return([mock_import_history])
      EpiSurveyor::Survey.should_receive(:find).with(1).and_return(survey)
      get :index, :survey_id => 1
      assigns(:import_histories).should eq([mock_import_history])
    end
    
    it 'call ImportHistory.all if survey_id is nil' do
      ImportHistory.should_receive(:all).and_return([])
      get :index
      assigns(:import_histories).should == []
    end
  end

  describe "GET show" do
    it "assigns the requested import_history as @import_history" do
      ImportHistory.stub(:find).with("37") { mock_import_history }
      get :show, :survey_id => 1, :id => "37"
      assigns(:import_history).should be(mock_import_history)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested import_history" do
      ImportHistory.stub(:find).with("37") { mock_import_history }
      mock_import_history.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the import_histories list" do
      ImportHistory.stub(:find) { mock_import_history }
      mock_import_history.should_receive(:survey_id).and_return(1)
      delete :destroy, :survey_id => 1, :id => "1"
      response.should redirect_to(survey_import_histories_url(1))
    end
  end

end
