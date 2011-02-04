class SalesforceObjectFactory
  def self.create type_name
    case type_name
    when 'Monitoring_Visit__c' : MvDistrictSurveyResponse.new
    end
  end
end