module Salesforce
  module Queries
  
    module InstanceMethods
      
      def save!
        self.id.present? ? update! : create!
      end
      
      def create!
        sanitize_values!
        response = Salesforce::Binding.instance.create("sObject {\"xsi:type\" => \"#{self.class.object_type}\"}" => field_values)
        self.id = response.createResponse.result.id
      end
      
      def update!
        raise ArgumentError.new("Id is nil") if self.id.nil?
        sanitize_values!
        response = Salesforce::Binding.instance.update("sObject {\"xsi:type\" => \"#{self.class.object_type}\"}" => field_values)
        self.id = response.updateResponse.result.id
      end
    
      def sanitize_values!
        field_values.each_pair do |field, value|
          next if value.nil?
          the_value = value.to_s.strip
          field_values[field] = 'true' if the_value.downcase == 'yes'
          field_values[field] = 'false' if the_value.downcase == 'no'
          field_values[field] = nil if the_value.downcase == 'n/a'        
          field_values[field] = the_value.gsub(/\|/, ';') if the_value.include?("|")        
        end
      end
    end
  
    module ClassMethods
      def get_first_record field, object_name, conditions 
        query = "SELECT #{field.to_s} FROM #{object_name.to_s} WHERE #{conditions}"
        answer = Salesforce::Binding.instance.query(:searchString => query)
        records = answer.queryResponse.result.records
        record = records.is_a?(Array) ? records.first : records
        record.present? ? record.send(field) : nil
      end
    end
  end
end