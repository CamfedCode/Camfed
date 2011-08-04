require 'spec_helper'
require 'controllers/authentication_helper'

describe ImportHistoriesController do
  before(:each) do
    sign_on
  end

  describe "GET index" do
    it "assigns all import_histories as @import_histories" do
      ImportHistory.should_receive(:get_by_filter).with(1, "All", "2011/07/20", "2011/07/21").and_return([mock_import_history])
      get :index, :survey_id => 1, :status => "All", :start_date => "2011/07/20", :end_date => "2011/07/21"
      assigns(:import_histories).should eq([mock_import_history])
    end
    
    it 'should return all import histories when no filter criteria is specified' do
      ImportHistory.should_receive(:get_by_filter).with(nil, "All", nil, nil).and_return([mock_import_history])
      get :index, :survey_id => nil, :status => "All", :start_date => "", :end_date => ""
      assigns(:import_histories).should eq([mock_import_history])
    end

    it 'should set end date to now if the start date is specified but the end date is not' do
      ImportHistory.should_receive(:get_by_filter).with(nil, "All", "2011/07/20", an_instance_of(Time)).and_return([mock_import_history])
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
    
    it "destroys the requested import_history" do
      ImportHistory.stub(:find).with("37") { mock_import_history }
      mock_import_history.should_receive(:destroy)
      request.env["HTTP_REFERER"] = import_histories_path
      delete :destroy, :id => "37"
      response.should redirect_to import_histories_path
    end

  end

end
