require "spec_helper"
require "method_hash_helper"

describe SalesforceQueries do
  
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
      SalesforceBinding.should_receive(:instance).and_return(binding)
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      mv_salesforce_object = SampleSalesforceObject.new
      result = SampleSalesforceObject.get_first_record(:Id, :School__c, "name='School A'")
      result.should == "1"
    end
    
  end
  
  describe 'create!' do
    it 'should call binding with the parameters to create' do
      binding = ''
      SalesforceBinding.should_receive(:instance).and_return(binding)
      response = method_hash_from_hash(:createResponse=>{:result=>{ :id => 1}})      
      binding.should_receive(:create).with("sObject {\"xsi:type\" => \"AnObject\"}" => {:name => 'Hi'}).and_return(response)
      new_object = SampleSalesforceObject.new
      new_object[:name] = 'Hi'
      new_object.create!.should == 1
    end
  end
    # 
    # def hash_to_method_hash a_hash_or_value
    # 
    #   if a_hash_or_value.is_a?(Array)
    #     return a_hash_or_value.collect{|item| hash_to_method_hash(item)}
    #   end
    # 
    #   return a_hash_or_value unless a_hash_or_value.is_a?(Hash)
    # 
    #   method_hash = RForce::MethodHash.new
    #   a_hash_or_value.each_pair do |key, value|
    #     method_hash[key] = hash_to_method_hash(value)
    #   end
    #   method_hash
    # end
  
end

class SampleSalesforceObject < SalesforceObject
  def self.object_type
    "AnObject"
  end
end