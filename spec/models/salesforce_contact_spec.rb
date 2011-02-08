require "spec_helper"
require "method_hash_helper"

describe SalesforceContact do
  
  describe 'init' do
    it 'should set object type' do
      SalesforceContact.object_type.should == 'Contact'
    end
  end
  
  describe 'get_first_or_create' do
    it "should return the id of the first one matching" do
      SalesforceContact.should_receive(:get_first_record).with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(1)
      SalesforceContact.get_first_or_create('John Doe').should == 1
    end
    
    it "should return the id of a newly created on if none found" do
      SalesforceContact.should_receive(:get_first_record).with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(nil)
      binding = ''
      SalesforceBinding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1}})
      #response.createResponse.result.id
      binding.should_receive(:create).and_return(response)
      SalesforceContact.get_first_or_create('John Doe').should == 1
    end
  end
  
end