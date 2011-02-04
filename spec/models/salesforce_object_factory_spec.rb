require "spec_helper"

describe SalesforceObjectFactory do
  describe 'create' do
    it 'should create MvSalesforceObject when passed Monitoring_Visit__c' do
      SalesforceObjectFactory.create('Monitoring_Visit__c').is_a?(MvSalesforceObject).should be true
    end
  end
end