class SalesforceContact < SalesforceObject
  
  def self.object_type
    "Contact"
  end

  def self.get_first_or_create name
    first_name, last_name = name.split(' ')
    contact = get_first_record(:Id, object_type, "FirstName='#{first_name}' AND LastName='#{last_name}'")
    return contact if contact
    
    new_contact = SalesforceContact.new
    new_contact[:FirstName] = first_name
    new_contact[:LastName] = last_name
    new_contact.create!
    new_contact.id
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