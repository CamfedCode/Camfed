module Salesforce
  class ObjectFactory
    def self.create type_name
      "Salesforce::#{class_name_from_object_name(type_name)}".constantize.new
    end
    
    def self.class_name_from_object_name object_name
      object_name.sub(/__c/, '').camelize
    end
  end
end