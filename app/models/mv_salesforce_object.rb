class MvSalesforceObject < SalesforceObject
  SALES_FORCE_OBJECT_NAME='Monitoring_Visit__c'
  
  def binding
    unless @binding
      @binding = RForce::Binding.new 'https://test.salesforce.com/services/Soap/u/20.0'
      @binding.login 'sf_sysadmin@camfed.org.dean', 'w3stbrookLidRts9sALeXQYTYhYJUvl5wc'
    end
    @binding
  end
  
  def binding=(value)
    @binding = value
  end
  
  def sync!
    field_values_hash = {:Date__c => '2011-02-07',
                          :School__c => 'Riversdale primary school',
                          #:Monitor__c => {:Id => -1466016902},
                          :CPP_in_pace => true}
    field_values_hash = replace_field_values_with_id
    
    response = binding.query(:searchString => "SELECT Id, name FROM School__c")
    # 
    # response = binding.create("sObject {\"xsi:type\" => \"#{SALES_FORCE_OBJECT_NAME}\"}" => field_values_hash)
    puts response
  end
  
  
  def replace_field_values_with_id
    self[:School__c] = get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")
    self[:Monitor__c] = get_first_record(:Id, :Monitor__c, "name='#{self[:Monitor__c]}'")
  end
  
  def get_first_record field, object_name, conditions 
    query = "SELECT #{field.to_s} FROM #{object_name.to_s} WHERE #{conditions}"
    answer = binding.query(:searchString => query)
    records = answer.queryResponse.result.records
    record = records.is_a?(Array) ? records.first : records
    record.send(field)
  end
  
  
  
end
