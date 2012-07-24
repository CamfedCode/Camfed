module Salesforce
  module Queries
  
    module InstanceMethods
      
      def save_in_salesforce!
        self.salesforce_id.present? ? update_in_salesforce! : create_in_salesforce!
      end
      
      def create_in_salesforce!
        sanitize_values!
        response = Salesforce::Binding.instance.create("sObject {\"xsi:type\" => \"#{self.name}\"}" => field_values)
        
        raise_if_fault response, raw_request

        if response.createResponse.result.success.to_s.downcase == false.to_s
          sync_error = SyncError.new(:raw_request => raw_request,
            :raw_response => response.createResponse.result.errors.message,
            :salesforce_object => self.name)
          raise SyncException.new(sync_error)
        end

        self.salesforce_id = response.createResponse.result.id
        Salesforce::ObjectHistory.new(:salesforce_object => self.name, :salesforce_id => self.salesforce_id)
      end
      
      def update_in_salesforce!
        raise ArgumentError.new("salesforce_id is nil") if self.salesforce_id.nil?
        sanitize_values!
        response = Salesforce::Binding.instance.update("sObject {\"xsi:type\" => \"#{self.name}\"}" => field_values)

        raise_if_fault response, raw_request

        if response.updateResponse.result.success.to_s.downcase == false.to_s
          sync_error = SyncError.new(:raw_request => raw_request, 
            :raw_response => response.updateResponse.result.errors.message,
            :salesforce_object => self.name)
          raise SyncException.new(sync_error)
        end

        self.salesforce_id = response.updateResponse.result.id
        Salesforce::ObjectHistory.new(:salesforce_object => self.name, :salesforce_id => self.salesforce_id)
      end
      
      def salesforce_fields
        return @salesforce_fields if @salesforce_fields
        response = Salesforce::Binding.instance.describeSObject("sObjectType" => self.name)
        result =  response.describeSObjectResponse.result
        return [] if result.nil? || result.fields.nil?        
        @salesforce_fields = result.fields.collect {|field| Field.new(field.name, field.label, field.type)}
      end
    
      def sanitize_values!
        self.field_values.symbolize_keys!
        field_values[:Id] = self.salesforce_id if self.salesforce_id.present?

        field_values.each_pair do |field, value|
          next if value.nil?
          the_value = englishify(value, value)
          field_values[field] = the_value

          #Skip EpiSurveyor uses "~" when a previous answer invalidates the question
          #E.g.   
          #     Q1: Did you receive SNF? A: No
          #     Q2: What amount was Received? A: ~, since Q1 was No

          field_values[field] = nil if the_value == '~'
          field_values[field] = 'true' if the_value.to_s.strip.downcase == 'yes' unless /maybe/=~ field.to_s
          field_values[field] = 'false' if the_value.to_s.strip.downcase == 'no' unless /maybe/=~ field.to_s

          field_values[field] = the_value.to_s.gsub(/\|/, ';') if the_value.to_s.include?("|")

          ## this is important
          ## FAQ:"To prevent SOQL injection, use an escapeSingleQuotes method."
          ##field_values[field] = the_value.escape_single_quotes if the_value.include?("'")
        end
      end
            
      def englishify field, value
        if value.to_s.include?("|") then
          find_array = value.split("|")
          find_array.each do |val|
            value.gsub!(val, englishify(val, val))
          end
        end
        value = REDIS.get(field) if REDIS.get(field)
        value
      end

      def raise_if_fault response, raw_request
        if response.try(:Fault).try(:faultstring)
          sync_error = SyncError.new(:raw_request => raw_request, 
            :raw_response => response.Fault.faultstring,
            :salesforce_object => self.name)
          raise SyncException.new(sync_error)
        end
        
      end
    end
  
    module ClassMethods
      def first_from_salesforce field, object_name, conditions
        records = all_from_salesforce(field, object_name, conditions)
        return nil if records.length != 1
        records.first.send(field)
      end
      
      def all_from_salesforce field, object_name, conditions 
        query = "SELECT #{field.to_s} FROM #{object_name.to_s} WHERE #{conditions}"

        Rails.logger.info "  All From Salesforce Query: #{query}"
        
        answer = Salesforce::Binding.instance.query(:searchString => query)
        
        Rails.logger.info "  All From Salesforce Answer: #{answer}"
        
        records = answer.queryResponse.result.records
        
        return [] if records.nil?
        records.is_a?(Array) ? records : [records]
      end
      
      def fetch_all_objects
        response = Salesforce::Binding.instance.describeGlobal({})
        
        all_objects = response.describeGlobalResponse.result.sobjects.collect do |description|
          new(:name => description.name, :label => description.label)
        end
        
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
