require "spec_helper"

describe Salesforce::ObjectFactory do
  describe 'create' do
    it 'should create MonitoringVisit when passed Monitoring_Visit__c' do
      Salesforce::ObjectFactory.create('Monitoring_Visit__c').is_a?(Salesforce::MonitoringVisit).should be true
    end
  end
end