module Salesforce
  class ObjectFactory
    def self.create type_name
      case type_name.to_s
      when 'Monitoring_Visit__c' then Salesforce::MonitoringVisit.new
      end
    end
  end
end