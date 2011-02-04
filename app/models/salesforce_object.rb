class SalesforceObject
  
  attr_accessor :field_values
  
  def create record_type, record
    binding = RForce::Binding.new 'https://www.salesforce.com/services/Soap/u/20.0'
    binding.login 'smsohan@thoughtworks.com', 'sf2011sohanU8I2AbvULgtA2WMU6NWKSOkk'
    
    response = binding.create("sObject {\"xsi:type\" => \"#{record_type}\"}" => record)
    puts response
  end
  
  def [](field_name)
    field_values[field_name]
  end

  def []=(field_name, value)
    field_values[field_name] = value
  end
  
  
  # def sf_test
  #   binding = RForce::Binding.new 'https://www.salesforce.com/services/Soap/u/20.0'
  # 
  #   binding.login 'smsohan@thoughtworks.com', 'sf2011sohanU8I2AbvULgtA2WMU6NWKSOkk'
  # 
  #   answer = binding.query(:searchString => 'SELECT FirstName, LastName FROM Contact')
  #   puts answer
  # 
  #   me = {:Email => 'foobar@test.com', :lastName => 'bar'}
  #   result = binding.create('sObject {"xsi:type" => "Contact"}' => me)
  #   puts result
  # end
end