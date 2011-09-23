module Salesforce
  class Base < ActiveRecord::Base
    include Salesforce::Queries::InstanceMethods
    extend Salesforce::Queries::ClassMethods

    set_table_name 'salesforce_objects'
    
    attr_accessor :field_values, :salesforce_id

    after_initialize do
      self.field_values = {}
    end
  
    def [](field_name)
      field_values[field_name]
    end

    def []=(field_name, value)
      field_values[field_name] = value
    end
  
    def sync!
      save_in_salesforce!
    end
    
    def raw_request
      field_values.keys.collect{|key| "#{key}: #{field_values[key]}"}.join(', ')
    end
    
  end
end