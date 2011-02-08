class MvSalesforceObject < SalesforceObject  

  def sync!
    self.field_values.symbolize_keys!
    replace_field_values_with_id
    create!
  end
  
  def self.object_type
    "Monitoring_Visit__c"
  end
  
  def replace_field_values_with_id
    self[:School__c] = MvSalesforceObject.get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")
    self[:Monitor__c] = SalesforceContact.get_first_or_create(self[:Monitor__c])
    self[:TM__c] = SalesforceContact.get_first_or_create(self[:TM__c])
  end

end
