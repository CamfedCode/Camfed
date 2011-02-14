require 'spec_helper'
require 'controllers/authentication_helper'

describe Admin::ConfigurationsController do
  
  before(:each) do
    sign_on
  end
  
  describe "GET 'edit'" do
    it "should load the current configuration" do
      configuration = Configuration.new
      Configuration.should_receive(:instance).and_return(configuration)
      get 'edit'      
      response.should be_success
      assigns[:configuration].should == configuration
    end
  end

  describe "PUT 'update'" do
    it "should get the current instance and update the values" do
      configuration = Configuration.new
      params = {:configuration => {}}
      configuration.should_receive(:update_attributes).with(params[:configuration]).and_return(true)
      Configuration.should_receive(:instance).and_return(configuration)
      put 'update', :id => 1, :configuration => params[:configuration]      
      response.should redirect_to root_path
      assigns[:configuration].should == configuration
      flash[:notice].should == 'Successfully updated the configuration changes'
    end
  end
  
  describe "POST 'create'" do
    it "should create a new instance" do
      configuration = Configuration.new
      params = {:configuration => {}}
      configuration.should_receive(:save).and_return(true)
      Configuration.should_receive(:new).with(params[:configuration]).and_return(configuration)
      post 'create', :configuration => params[:configuration]      
      response.should redirect_to root_path
      assigns[:configuration].should == configuration
      flash[:notice].should == 'Successfully created the configuration changes'
    end
  end
  
  after(:each) do
    Configuration.rspec_reset
  end
  
  
  
end