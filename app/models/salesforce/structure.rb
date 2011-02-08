module Salesforce
  class Structure < Base
    def self.object_type
      "Structure__c"
    end
  
    def replace_field_values_with_id
      self[:School__c] = self.class.get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")      
      self[:RecordTypeId] = self.class.get_first_record(:Id, :RecordType, "name='#{self[:RecordTypeId]}'")
    end
    
    def sync!
      self.field_values.symbolize_keys!
      replace_field_values_with_id
      
      self.id = self.class.get_first_record(:Id, self.class.object_type, find_conditions)
      save!
    end
    
    def find_conditions
      "School__c='#{self[:School__c]}' AND RecordTypeId='#{self[:RecordTypeId]}' AND Group_Name__c='#{self[:Group_Name__c]}'"
    end
    
  end
end