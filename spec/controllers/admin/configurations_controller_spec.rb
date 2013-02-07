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

  describe "POST send_sms" do
    def create_mock_twilio_message
      mock_client = ""
      mock_account = ""
      mock_sms = ""
      mock_messages = ""
      Twilio::REST::Client.should_receive(:new).and_return(mock_client)
      mock_client.should_receive(:account).and_return(mock_account)
      mock_account.should_receive(:sms).and_return(mock_sms)
      mock_sms.should_receive(:messages).and_return(mock_messages)
      mock_messages
    end

    it("should send sms using Twilio") do
      from_number = TWILIO_CONFIG[Rails.env]["from_number"]
      request_params = {:number => "+1234567890", :message => "SMS text"}
      mock_messages = create_mock_twilio_message()
      mock_messages.should_receive(:create).with({:from => from_number, :to => request_params[:number], :body => request_params[:message]})

      post 'send_sms' , request_params

      flash[:error].should include "Error" unless flash[:error].nil? #Additional check to ensure that on failure for better reporting.
      flash[:notice].should == 'Successfully sent the sms'
      response.should redirect_to(edit_admin_configuration_path)
    end

    it("should fail to send the message when message length is greater than 160") do
      expected_error_message = "Some exception occurred"

      from_number = TWILIO_CONFIG[Rails.env]["from_number"]
      request_params = {:number => "+1234567890", :message => "SMS text"}
      mock_messages = create_mock_twilio_message()
      mock_messages.should_receive(:create).with({:from => from_number, :to => request_params[:number], :body => request_params[:message]}).and_raise(expected_error_message)

      post 'send_sms' , request_params

      flash[:error].should include(expected_error_message)

      response.should redirect_to(edit_admin_configuration_path)
    end
  end
  
  after(:each) do
    Configuration.rspec_reset
  end
  
  
  
end