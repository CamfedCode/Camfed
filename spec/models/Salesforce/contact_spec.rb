require "spec_helper"
require "method_hash_helper"


describe Salesforce::Contact do
  
  describe 'init' do
    it 'should set object type' do
      Salesforce::Contact.object_type.should == 'Contact'
    end
  end
  
  describe 'get_first_or_create' do
    it "should return the id of the first one matching" do
      Salesforce::Contact.should_receive(:get_first_record).with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(1)
      Salesforce::Contact.get_first_or_create('John Doe').should == 1
    end
    
    it "should return the id of a newly created on if none found" do
      Salesforce::Contact.should_receive(:get_first_record).with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(nil)
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1}})
      #response.createResponse.result.id
      binding.should_receive(:create).and_return(response)
      Salesforce::Contact.get_first_or_create('John Doe').should == 1
    end
  end
  
end