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
  
  def sync!
    self.field_values.symbolize_keys!
    replace_field_values_with_id
    create!    
  end
  
  def replace_field_values_with_id; end

end