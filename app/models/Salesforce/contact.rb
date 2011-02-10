module Salesforce
  class Contact < Base
  
    def self.object_type
      "Contact"
    end

    def self.first_or_create name
      return nil if name.blank?
      
      first_name, last_name = name.split(' ')
      contacts = all(:Id, object_type, "FirstName='#{first_name}' AND LastName='#{last_name}'")
      return nil if contacts.length > 1
      return contacts.first.Id if contacts.length == 1
    
      new_contact = Contact.new
      new_contact[:FirstName] = first_name
      new_contact[:LastName] = last_name
      new_contact.create!
      new_contact.id
    end

  end
end