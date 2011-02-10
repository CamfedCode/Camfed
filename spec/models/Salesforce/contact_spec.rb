require "spec_helper"
require "method_hash_helper"


describe Salesforce::Contact do
  
  describe 'init' do
    it 'should set object type' do
      Salesforce::Contact.object_type.should == 'Contact'
    end
  end
  
  describe 'first_or_create' do
    it "should return the id if one match found" do
      single_match = [method_hash_from_hash(:Id => 1)]
      Salesforce::Contact.should_receive(:all)
        .with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(single_match)
      Salesforce::Contact.first_or_create('John Doe').should == 1
    end
    
    it 'should return nil if more than one match found' do
      multiple_matches = [1,2]
      Salesforce::Contact.should_receive(:all)
        .with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(multiple_matches)
      Salesforce::Contact.first_or_create('John Doe').should be nil
    end
    
    it "should return the id of a newly created on if none found" do
      no_match = []
      Salesforce::Contact.should_receive(:all)
        .with(:Id, "Contact", "FirstName='John' AND LastName='Doe'")
        .and_return(no_match)
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1}})
      binding.should_receive(:create).and_return(response)
      Salesforce::Contact.first_or_create('John Doe').should == 1
    end
    
    it 'should return nil if name is blank' do
      Salesforce::Contact.first_or_create('').should be nil
    end
    it 'should return nil if name is nil' do
      Salesforce::Contact.first_or_create(nil).should be nil
    end

  end
  
end