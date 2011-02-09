require "spec_helper"

describe ImportHistoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/import_histories" }.should route_to(:controller => "import_histories", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/import_histories/1" }.should route_to(:controller => "import_histories", :action => "show", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/import_histories/1" }.should route_to(:controller => "import_histories", :action => "destroy", :id => "1")
    end

  end
end
