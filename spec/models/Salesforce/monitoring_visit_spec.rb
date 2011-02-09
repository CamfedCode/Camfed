require "spec_helper"

describe Salesforce::MonitoringVisit do

  describe 'object_type' do
    it 'should be Monitoring_Visit__c' do
      Salesforce::MonitoringVisit.object_type.should == 'Monitoring_Visit__c'
    end 
  end
  
  describe "replace_field_values_with_id" do

    it "should call lookup for school id" do
      Salesforce::Contact.should_receive(:get_first_or_create).with('A Monitor').and_return("2")
      Salesforce::MonitoringVisit.should_receive(:first).with(:Id, :School__c, "name='School A'").and_return("1")
      Salesforce::Contact.should_receive(:get_first_or_create).with('A TM').and_return("3")
      mv_salesforce_object = Salesforce::MonitoringVisit.new
      mv_salesforce_object.field_values = {:School__c => 'School A', :Monitor__c => "A Monitor", :TM__c =>'A TM'}
      mv_salesforce_object.replace_field_values_with_id
      mv_salesforce_object[:School__c].should == "1"
      mv_salesforce_object[:Monitor__c].should == "2"
      mv_salesforce_object[:TM__c].should == "3"
    end      
  end
  
  describe 'sync!' do
    before(:each) do
      @mv_salesforce_object = Salesforce::MonitoringVisit.new
      @mv_salesforce_object['School__c'] = 'A School'
      @mv_salesforce_object.stub!(:create!)
      @mv_salesforce_object.stub!(:replace_field_values_with_id)
    end
    
    it 'should symbolize keys' do
      @mv_salesforce_object.sync!
      @mv_salesforce_object.field_values.keys.include?(:School__c).should be true
    end
  end
  
end