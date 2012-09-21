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
      ImportHistory.should_receive(:get_by_filter).with(1, "All", "2011/07/20", "2011/07/21").and_return([mock_import_history])
      get :index, :survey_id => 1, :status => "All", :start_date => "2011/07/20", :end_date => "2011/07/21"
      assigns(:import_histories).should eq([mock_import_history])
    end
    
    it 'should import histories for pat 45 days when no filter criteria is specified' do
      today = Date.today
      forty_five_days_ago = today - 45
      ImportHistory.should_receive(:get_by_filter).with(nil, "All", forty_five_days_ago, today).and_return([mock_import_history])
      get :index, :survey_id => nil, :status => "All", :start_date => "", :end_date => ""
      assigns(:import_histories).should eq([mock_import_history])
    end

    it 'should set end date to now if the start date is specified but the end date is not' do
      ImportHistory.should_receive(:get_by_filter).with(nil, "All", "2011/07/20", Date.today).and_return([mock_import_history])
      get :index, :survey_id => nil, :status => "All", :start_date => "2011/07/20", :end_date => ""
      assigns(:import_histories).should eq([mock_import_history])
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
    
    it "destroys the requested import_histories" do
      ImportHistory.stub(:find).with("37") { mock_import_history }
      request.env["HTTP_REFERER"] = import_histories_path
      delete :destroy_selected, :id => "37"
      response.should redirect_to import_histories_path
    end

  end

end
