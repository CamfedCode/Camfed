require 'spec_helper'
require 'controllers/authentication_helper'

describe SalesforceObjectsController do
  before(:each) do
    sign_on
  end
  
  describe 'index' do
    it 'should populate a list of all salesforce objects' do
      Salesforce::Base.should_receive(:all).and_return([])
      get 'index'
      assigns[:salesforce_objects].should == []
      response.should be_success
    end
  end


  describe 'POST to fetch_all' do
    it 'should fetch all objects from Salesforce' do
      Salesforce::Base.should_receive(:fetch_all_objects).and_return([])
      post 'fetch_all'
      assigns[:salesforce_objects].should == []
      response.should redirect_to salesforce_objects_path
      flash[:notice].should == "Successfully updated the list of all salesforce objects"
    end
  end

  describe 'PUT to enable' do
    it 'should mark as enable=true ' do
      an_object = Salesforce::Base.create(:name => 'an_object', :label => 'an object')
      Salesforce::Base.should_receive(:find).and_return(an_object)
      put 'enable', :id => an_object.id
      assigns[:salesforce_object].should == an_object
      assigns[:salesforce_object].enabled.should be true
      flash[:notice].should == "Successfully enabled an object"
      response.should redirect_to salesforce_objects_path
    end
  end

  describe 'PUT to disable' do
    it 'should mark as enable=false ' do
      an_object = Salesforce::Base.create(:name => 'an_object', :label => 'an object')
      Salesforce::Base.should_receive(:find).and_return(an_object)
      put 'disable', :id => an_object.id
      assigns[:salesforce_object].should == an_object
      assigns[:salesforce_object].enabled.should be false
      flash[:notice].should == "Successfully disabled an object"
      response.should redirect_to salesforce_objects_path
    end
  end

  
end