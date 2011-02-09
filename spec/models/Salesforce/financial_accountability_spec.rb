require "spec_helper"

describe Salesforce::FinancialAccountability do

  describe 'object_type' do
    it 'should be Monitoring_Visit__c' do
      Salesforce::FinancialAccountability.object_type.should == 'Financial_Accountability__c'
    end 
  end
  
  describe "replace_field_values_with_id" do
    describe 'the mocked first' do
      fm_salesforce_object = Salesforce::FinancialAccountability.new
      it "should call lookup for school id" do
        Salesforce::FinancialAccountability.should_receive(:first).with(:Id, :School__c, "name='School A'").and_return("1")
        fm_salesforce_object.field_values = {:School__c => 'School A'}
        fm_salesforce_object.replace_field_values_with_id
        fm_salesforce_object[:School__c].should == "1"
      end      
    end
  end
  
end