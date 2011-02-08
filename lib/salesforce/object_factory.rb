module Salesforce
  class ObjectFactory
    def self.create type_name
      case type_name.to_s
        when 'Monitoring_Visit__c' then Salesforce::MonitoringVisit.new
        when 'Financial_Accountability__c' then Salesforce::FinancialAccountability.new
        when 'Structure__c' then Salesforce::Structure.new
      end
    end
  end
end