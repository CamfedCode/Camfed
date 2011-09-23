module Salesforce
  class Binding
    def self.instance
      unless defined?(@@binding)
        @@binding = RForce::Binding.new Configuration.instance.salesforce_url
        
        user_name = Configuration.instance.salesforce_user
        salesforce_token = Configuration.instance.salesforce_token
        begin
          @@binding.login user_name, salesforce_token
        rescue Exception=> e
          Rails.logger.error "Could not log in with #{user_name} and #{salesforce_token}"
          raise e
        end
      end
      @@binding
    end
  end
end