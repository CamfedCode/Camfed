require "spec_helper"

describe Salesforce::ChildProtection do

  describe 'object_type' do
    it 'should be Child_Protection__c' do
      Salesforce::ChildProtection.object_type.should == 'Child_Protection__c'
    end 
  end
  
  describe "replace_field_values_with_id" do
    describe 'the mocked get_first_record' do
      cp_salesforce_object = Salesforce::ChildProtection.new
      it "should call lookup for school id" do
        Salesforce::ChildProtection.should_receive(:get_first_record).with(:Id, :School__c, "name='School A'").and_return("1")
        cp_salesforce_object.field_values = {:School__c => 'School A'}
        cp_salesforce_object.replace_field_values_with_id
        cp_salesforce_object[:School__c].should == "1"
      end      
    end
  end
  
end