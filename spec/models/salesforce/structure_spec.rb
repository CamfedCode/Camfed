require "spec_helper"

describe Salesforce::Structure do

  describe 'object_type' do
    it 'should be Monitoring_Visit__c' do
      Salesforce::Structure.object_type.should == 'Structure__c'
    end 
  end
  
  describe "replace_field_values_with_id" do

    it "should call lookup for school id" do
      Salesforce::Structure.should_receive(:first_from_salesforce).with(:Id, :RecordType, "name='Mothers Support Group'").and_return("2")
      Salesforce::Structure.should_receive(:first_from_salesforce).with(:Id, :School__c, "name='School A'").and_return("1")
      structure = Salesforce::Structure.new
      structure.field_values = {:School__c => 'School A', :RecordTypeId => 'Mothers Support Group', :Monitor__c => "A Monitor", :TM__c =>'A TM'}
      structure.replace_field_values_with_id
      structure[:School__c].should == "1"
      structure[:RecordTypeId].should == "2"
    end      
  end
  
  describe 'sync!' do
    it 'should should save_in_salesforce!' do
      structure = Salesforce::Structure.new
      structure.stub!(:replace_field_values_with_id)
      structure.should_receive(:find_conditions).and_return('a=b')
      Salesforce::Structure.should_receive(:first_from_salesforce).with(:Id, 'Structure__c', 'a=b')
      structure.should_receive(:save_in_salesforce!)
      structure.sync!
    end
  end
  
  describe 'find_conditions' do
    it "should generate the condition from fields" do
      structure = Salesforce::Structure.new
      structure[:School__c] = "1"
      structure[:RecordTypeId] = "2"
      structure[:Group_Name__c] = "a group"
      structure.find_conditions.should == "School__c='1' AND RecordTypeId='2' AND Group_Name__c='a group'"
    end
  end
  
end