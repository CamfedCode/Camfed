require "spec_helper"
require "method_hash_helper"

describe Salesforce::Queries do
  
  describe 'get_first_record' do
    it 'should return the first record if there are many' do
      answer = method_hash_from_hash(
                {:queryResponse=>{:result=>{:done=>"true", :queryLocator=>nil, 
                  :records=>[ 
                    {:type=>"School__c", :Id=>"1"},
                    {:type=>"School__c", :Id=>"2"}
                    ],            
                  :size=>"2"}}}
                )
      query = "SELECT Id FROM School__c WHERE name='School A'"
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      mv_salesforce_object = SampleSalesforceObject.new
      result = SampleSalesforceObject.get_first_record(:Id, :School__c, "name='School A'")
      result.should == "1"
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
    it 'should call binding with the parameters to create' do
      binding = ''
      Salesforce::Binding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1}})      
      binding.should_receive(:create).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:name => 'Hi'}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object[:name] = 'Hi'
      new_object.create!.should == 1
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
      response = method_hash_from_hash(:updateResponse=>{:result=>{ :id => 1}})      
      binding.should_receive(:update).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:Id => 1}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object.id = 1
      new_object.update!
      new_object.id.should == 1
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