class SalesforceObjectFactory
  def self.create type_name
    case type_name
    when 'Monitoring_Visit__c' then MvSalesforceObject.new
    end
  end
end