module Salesforce
  class Binding
    def self.instance
      unless defined?(@@binding)
        @@binding = RForce::Binding.new 'https://test.salesforce.com/services/Soap/u/20.0'
        @@binding.login 'sf_sysadmin@camfed.org.dean', 'w3stbrookLidRts9sALeXQYTYhYJUvl5wc'
      end
      @@binding
    end
  end
end