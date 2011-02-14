module Salesforce
  class Binding
    def self.instance
      unless defined?(@@binding)
        @@binding = RForce::Binding.new Configuration.instance.salesforce_url
        @@binding.login Configuration.instance.salesforce_user, Configuration.instance.salesforce_token
      end
      @@binding
    end
  end
end