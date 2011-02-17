module Salesforce
  module Queries
  
    module InstanceMethods
      
      def save_in_salesforce!
        self.salesforce_id.present? ? update_in_salesforce! : create_in_salesforce!
      end
      
      def create_in_salesforce!
        sanitize_values!
        response = Salesforce::Binding.instance.create("sObject {\"xsi:type\" => \"#{self.class.object_type}\"}" => field_values)
        
        if response.createResponse.result.success.to_s == false.to_s
          raise SyncException.new(SyncError.new(:raw_request => raw_request, 
                :raw_response => response.createResponse.result.errors.message, :salesforce_object => self.class.object_type))
        end

        self.salesforce_id = response.createResponse.result.id
        Salesforce::ObjectHistory.new(:salesforce_object => self.class.object_type, :salesforce_id => self.salesforce_id)
      end
      
      def update_in_salesforce!
        raise ArgumentError.new("salesforce_id is nil") if self.salesforce_id.nil?
        sanitize_values!
        response = Salesforce::Binding.instance.update("sObject {\"xsi:type\" => \"#{self.class.object_type}\"}" => field_values)

        if response.updateResponse.result.success.to_s == false.to_s
          raise SyncException.new(SyncError.new(:raw_request => raw_request, 
                :raw_response => response.updateResponse.result.errors.message, :salesforce_object => self.class.object_type))
        end

        self.salesforce_id = response.updateResponse.result.id
        Salesforce::ObjectHistory.new(:salesforce_object => self.class.object_type, :salesforce_id => self.salesforce_id)
      end
      
      def salesforce_fields
        return @salesforce_fields if @salesforce_fields
        response = Salesforce::Binding.instance.describeSObject("sObjectType" => self.class.object_type)
        result =  response.describeSObjectResponse.result
        return [] if result.nil? || result.fields.nil?        
        @salesforce_fields = result.fields.collect {|field| Field.new(field.name, field.label, field.type)}
      end
    
      def sanitize_values!
        field_values[:Id] = self.salesforce_id if self.salesforce_id.present?

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
      def first_from_salesforce field, object_name, conditions
        record = all_from_salesforce(field, object_name, conditions).first 
        record.present? ? record.send(field) : nil
      end
      
      def all_from_salesforce field, object_name, conditions 
        query = "SELECT #{field.to_s} FROM #{object_name.to_s} WHERE #{conditions}"
        answer = Salesforce::Binding.instance.query(:searchString => query)
        records = answer.queryResponse.result.records
        
        return [] if records.nil?
        records.is_a?(Array) ? records : [records]
      end
      
      def fetch_all_objects
        response = Salesforce::Binding.instance.describeGlobal({})
        all_objects = response.describeGlobalResponse.result.sobjects.collect{|description| new(:name => description.name, :label => description.label)}
        
        all_objects.each do |an_object|
          unless where(:name => an_object.name).present?
            an_object.save!
          end
        end
        all
      end
    end
  end
end