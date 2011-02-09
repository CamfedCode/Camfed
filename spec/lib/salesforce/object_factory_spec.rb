require "spec_helper"

describe Salesforce::ObjectFactory do
  describe 'create' do
    it 'should create MonitoringVisit when passed Monitoring_Visit__c' do
      Salesforce::ObjectFactory.create('Monitoring_Visit__c').is_a?(Salesforce::MonitoringVisit).should be true
    end
    
    it 'should create Financial Accountability when passed Financial_Accountability__c' do
      Salesforce::ObjectFactory.create('Financial_Accountability__c').is_a?(Salesforce::FinancialAccountability).should be true
    end
    
    it 'should create Structure when passed Structure__c' do
      Salesforce::ObjectFactory.create('Structure__c').is_a?(Salesforce::Structure).should be true
    end

    it 'should create ChildProtection when passed Structure__c' do
      Salesforce::ObjectFactory.create('Child_Protection__c').is_a?(Salesforce::ChildProtection).should be true
    end
  end
end