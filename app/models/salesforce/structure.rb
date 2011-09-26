module Salesforce
  class Structure < Base
    def self.object_type
      "Structure__c"
    end
  
    def replace_field_values_with_id
      self[:School__c] = self.class.first_from_salesforce(:Id, :School__c, "name='#{self[:School__c]}'")      
      self[:RecordTypeId] = self.class.first_from_salesforce(:Id, :RecordType, "name='#{self[:RecordTypeId]}'").gsub(/'/,'')
    end
    
    def sync!
      self.field_values.symbolize_keys!
      replace_field_values_with_id
      
      self.salesforce_id = self.class.first_from_salesforce(:Id, self.class.object_type, find_conditions)
      save_in_salesforce!
    end
    
    def find_conditions
      "School__c='#{self[:School__c]}' AND RecordTypeId='#{self[:RecordTypeId]}' AND Group_Name__c='#{self[:Group_Name__c]}'"
    end
    
  end
end
