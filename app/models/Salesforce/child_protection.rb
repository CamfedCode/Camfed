module Salesforce
  class ChildProtection < Base
  
    def self.object_type
      "Child_Protection__c"
    end
  
    def replace_field_values_with_id
      self[:School__c] = self.class.first(:Id, :School__c, "name='#{self[:School__c]}'")
    end
    
  end
end