require "spec_helper"

describe MvSalesforceObject do
  
  describe "replace_field_values_with_id" do
    describe 'the mocked get_first_record' do
      mv_salesforce_object = MvSalesforceObject.new
      it "should call lookup for school id" do
        SalesforceContact.should_receive(:get_first_or_create).with('A Monitor').and_return("2")
        mv_salesforce_object.should_receive(:get_first_record).with(:Id, :School__c, "name='School A'")
          .and_return("1")
        SalesforceContact.should_receive(:get_first_or_create).with('A TM').and_return("3")

        mv_salesforce_object.field_values = {:School__c => 'School A', :Monitor__c => "A Monitor", :TM__c =>'A TM'}
        mv_salesforce_object.replace_field_values_with_id
        mv_salesforce_object[:School__c].should == "1"
        mv_salesforce_object[:Monitor__c].should == "2"
        mv_salesforce_object[:TM__c].should == "3"
      end      
    end
    
    
  end
  
end