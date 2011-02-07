module SalesforceQueries
  
  module InstanceMethods
    def create!
      response = SalesforceBinding.instance.create("sObject {\"xsi:type\" => \"#{self.class.object_type}\"}" => field_values)
      self.id = response.createResponse.result.id
    end
  end
  
  module ClassMethods
    def get_first_record field, object_name, conditions 
      query = "SELECT #{field.to_s} FROM #{object_name.to_s} WHERE #{conditions}"
      answer = SalesforceBinding.instance.query(:searchString => query)
      records = answer.queryResponse.result.records
      record = records.is_a?(Array) ? records.first : records
      record.present? ? record.send(field) : nil
    end
  end
end