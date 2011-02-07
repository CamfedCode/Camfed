class SalesforceObject
  include SalesforceQueries::InstanceMethods
  extend SalesforceQueries::ClassMethods
  
  attr_accessor :id, :field_values

  def initialize
    self.field_values = {}
  end
  
  def [](field_name)
    field_values[field_name]
  end

  def []=(field_name, value)
    field_values[field_name] = value
  end
  
end