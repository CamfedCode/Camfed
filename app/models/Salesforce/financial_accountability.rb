module Salesforce
  class FinancialAccountability < Base
  
    def self.object_type
      "Financial_Accountability__c"
    end
  
    def replace_field_values_with_id
      self[:School__c] = FinancialAccountability.get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")
    end
  
    def test
      self[:Notes__c] = 'A Note'
      self[:School__c] = 'Chatindo Secondary School'
      sync!
    end
  
  end
end