require "spec_helper"
require "method_hash_helper"

describe Salesforce::Queries do
  
  describe 'first' do
    it 'should return the first record if there are many' do
      answer = method_hash_from_hash(:type=>"School__c", :Id=>"1")
      mv_salesforce_object = SampleSalesforceObject.new
      SampleSalesforceObject.should_receive(:all).with(:Id, :School__c, "name='School A'").and_return([answer])
      result = SampleSalesforceObject.first(:Id, :School__c, "name='School A'")
      result.should == "1"
    end
    
  end
  
  describe 'all' do
    it 'should return an empty array if none matched' do
      answer = method_hash_from_hash(
                {:queryResponse=>{:result=>{:done=>"true", :queryLocator=>nil, :size=>"0"}}}
                )
      query = "SELECT Id FROM School__c WHERE name='School A'"
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      SampleSalesforceObject.all(:Id, :School__c, "name='School A'").should == []
    end

    it 'should return an array with one record if only one matched' do
      answer = method_hash_from_hash(
                {:queryResponse=>{:result=>{:done=>"true", :queryLocator=>nil, :records => {:Id => "1"}, :size=>"1"}}}
                )
      query = "SELECT Id FROM School__c WHERE name='School A'"
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      SampleSalesforceObject.all(:Id, :School__c, "name='School A'").should == [{:Id => "1"}]
    end

    it 'should return an array with all the items that matched' do
      answer = method_hash_from_hash(
                {:queryResponse=>{:result=>{:done=>"true", :queryLocator=>nil, :records => [{:Id => "1"}, {:Id => "2"}], :size=>"2"}}}
                )
      query = "SELECT Id FROM School__c WHERE name='School A'"
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      SampleSalesforceObject.all(:Id, :School__c, "name='School A'").should == [{:Id => "1"}, {:Id => "2"}]
    end


  end
  
  describe 'save' do
    it 'should call update when id is set' do
      sf_object = SampleSalesforceObject.new
      sf_object.should_receive(:update!)
      sf_object.id = 1
      sf_object.save!
    end
    
    it 'should call create when id is not set' do
      sf_object = SampleSalesforceObject.new
      sf_object.should_receive(:create!)
      sf_object.save!
    end
  end
  
  describe 'create!' do
    before(:each) do
      @binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(@binding)
    end
    
    it 'should call binding with the parameters to create' do
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1, :success => "true"}})      
      @binding.should_receive(:create).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:name => 'Hi'}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object[:name] = 'Hi'
      object_history = new_object.create!
      object_history.is_a?(Salesforce::ObjectHistory).should be true
      object_history.salesforce_id.should == 1
      object_history.salesforce_object.should == "AnObject"
    end
    
    it 'should raise error with raw response' do
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1, :success => "false", :errors => {:message => 'a'}}})      
      @binding.should_receive(:create).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:name => 'Hi'}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object[:name] = 'Hi'
      error_message = 'Object SampleSalesforceObject could not be created. FIELD_VALUES={:name=>"Hi"}. RAW_RESPONSE = {:createResponse=>{:result=>{:id=>1, :success=>"false"}}}'
      lambda {new_object.create!}.should raise_error(SyncException)
    end
    
  end
  
  describe 'update!' do
    it 'should throw exception when id not set' do
      sf_object = SampleSalesforceObject.new
      lambda {sf_object.update!}.should raise_error(ArgumentError)
      
    end
    
    it 'should call binding with the parameters to update' do
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:updateResponse=>{:result=>{ :id => 1, :success => 'true'}})      
      binding.should_receive(:update).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:Id => 1}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object.id = 1
      new_object.update!
      new_object.id.should == 1
    end
    
    it 'should raise error when success is false' do
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:updateResponse=>{:result=>{ :id => 1, :success => 'false', :errors => {:message => 'a'}}})      
      binding.should_receive(:update).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:Id => 1}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object.id = 1
      error_message = 'Object SampleSalesforceObject could not be updated. FIELD_VALUES={:Id=>1} RAW_RESPONSE = {:updateResponse=>{:result=>{:id=>1, :success=>"false"}}}'
      lambda {new_object.update!}.should raise_error(SyncException)
    end
    
    
  end
  
  describe 'fields' do
    before(:each) do
      @sf_object = SampleSalesforceObject.new
      @binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(@binding)
      
    end
    
    it 'should return empty when result is nil' do
      response = method_hash_from_hash(:describeSObjectResponse=>{:result=>nil})
      @binding.should_receive(:describeSObject).with("sObjectType" => "AnObject").and_return(response)
      @sf_object.fields.should == []
    end

    it 'should return empty when fields is nil' do
      response = method_hash_from_hash(:describeSObjectResponse=>{:result=>{:fields => nil}})
      @binding.should_receive(:describeSObject).with("sObjectType" => "AnObject").and_return(response)
      @sf_object.fields.should == []
    end

    it 'should return fields' do
      response = method_hash_from_hash(:describeSObjectResponse=>{:result=>{:fields => [
        {:type => 'string', :name => 'first_name', :label => 'first name'},
        {:type => 'string', :name => 'last_name', :label => 'last name'}
        ]}})
      @binding.should_receive(:describeSObject).with("sObjectType" => "AnObject").and_return(response)
      @sf_object.fields.should have(2).things
      first_field = Salesforce::Field.new('first_name', 'first name', 'string')
      last_field = Salesforce::Field.new('last_name', 'last name', 'string')
      @sf_object.fields.first.should == first_field
      @sf_object.fields.second.should == last_field
    end


  end
  
  describe 'sanitize_values!' do
    
    before(:each) do
      @sf_object = SampleSalesforceObject.new
      @sf_object[:CPP] = ' Yes '
      @sf_object[:CPP_placing] = ' No '
      @sf_object[:TM_c] = ' N/A '
      @sf_object[:Docs] = 'A|B'
      @sf_object.sanitize_values!      
    end
    
    it 'should change Yes to true' do
      @sf_object[:CPP].should == 'true'
    end

    it 'should change No to false' do
      @sf_object[:CPP_placing].should == 'false'
    end

    it 'should change N/A to false' do
      @sf_object[:TM_c].should == nil
    end

    it 'should replace | with ;' do
      @sf_object[:Docs].should == 'A;B'
    end

  end
  
end

class SampleSalesforceObject < Salesforce::Base
  def self.object_type
    "AnObject"
  end
end