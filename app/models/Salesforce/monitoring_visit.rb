module Salesforce  
  class MonitoringVisit < Base
  
    def self.object_type
      "Monitoring_Visit__c"
    end
  
    def replace_field_values_with_id
      self[:School__c] = self.class.first_from_salesforce(:Id, :School__c, "name='#{self[:School__c]}'")
      self[:Monitor__c] = Contact.first_or_create(self[:Monitor__c])
      self[:TM__c] = Contact.first_or_create(self[:TM__c])
    end

  end
end