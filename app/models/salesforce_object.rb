class SalesforceObject
  def create record_type, record
    binding = RForce::Binding.new 'https://www.salesforce.com/services/Soap/u/20.0'
    binding.login 'smsohan@thoughtworks.com', 'sf2011sohanU8I2AbvULgtA2WMU6NWKSOkk'
    
    response = binding.create("sObject {\"xsi:type\" => \"#{record_type}\"}" => record)
    puts response
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