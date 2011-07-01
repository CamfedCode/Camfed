module Salesforce
  class Binding
    def self.instance
      unless defined?(@@binding)
        @@binding = RForce::Binding.new Configuration.instance.salesforce_url
        
        user_name = Configuration.instance.salesforce_user
        salesforce_token = Configuration.instance.salesforce_token
        
        @@binding.login user_name, salesforce_token
      end
      @@binding
    end
  end
end