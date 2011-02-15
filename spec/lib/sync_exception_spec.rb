require 'spec_helper'

describe SyncException do
  describe 'init' do
    it 'should store the sync_error' do
      sync_error = SyncError.new(:raw_request => 'a', :raw_response =>'b', :salesforce_object => 'c' )
      sync_exception = SyncException.new(sync_error)
      
      sync_exception.sync_error.should == sync_error
      sync_exception.message.should == 'SyncError: Salesforce sync error. Salesforce Object:c Request:a Response:b'
      
    end
  end
  
end