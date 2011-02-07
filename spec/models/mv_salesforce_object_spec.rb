require "spec_helper"

describe MvSalesforceObject do
  
  describe 'get_first_record' do
    it 'should return the first record if there are many' do
      answer = hash_to_method_hash(
                {:queryResponse=>{:result=>{:done=>"true", :queryLocator=>nil, 
                  :records=>[ 
                    {:type=>"School__c", :Id=>"1"},
                    {:type=>"School__c", :Id=>"2"}
                    ],            
                  :size=>"2"}}}
                )
      query = "SELECT Id FROM School__c WHERE name='School A'"
      binding = ''
      binding.should_receive(:query).with({:searchString=>query}).and_return(answer)
      mv_salesforce_object = MvSalesforceObject.new
      mv_salesforce_object.binding = binding
      result = mv_salesforce_object.get_first_record(:Id, :School__c, "name='School A'")
      result.should == "1"
    end
    
  end
  
  describe "replace_field_values_with_id" do
    describe 'the mocked get_first_record' do
      mv_salesforce_object = MvSalesforceObject.new
      it "should call lookup for school id" do
        mv_salesforce_object.should_receive(:get_first_record).with(:Id, :School__c, "name='School A'")
          .and_return("1")
        mv_salesforce_object.should_receive(:get_first_record).with(:Id, :Monitor__c, "name='A Monitor'")
            .and_return("2")
        mv_salesforce_object.field_values = {:School__c => 'School A', :Monitor__c => "A Monitor"}
        mv_salesforce_object.replace_field_values_with_id
        mv_salesforce_object[:School__c].should == "1"
        mv_salesforce_object[:Monitor__c].should == "2"
      end      
    end
    
    
  end
  
  def hash_to_method_hash a_hash_or_value

    if a_hash_or_value.is_a?(Array)
      return a_hash_or_value.collect{|item| hash_to_method_hash(item)}
    end
    
    return a_hash_or_value unless a_hash_or_value.is_a?(Hash)
    
    method_hash = RForce::MethodHash.new
    a_hash_or_value.each_pair do |key, value|
      method_hash[key] = hash_to_method_hash(value)
    end
    method_hash
  end
  
end