class CpSalesforceObject < SalesforceObject
  
  def self.object_type
    "Child_Protection__c"
  end
  
  def replace_field_values_with_id
    self[:School__c] = CpSalesforceObject.get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")
  end
    
end