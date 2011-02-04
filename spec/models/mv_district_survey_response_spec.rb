require "spec_helper"

describe MvDistrictSurveyResponse do
  describe 'sync!' do
    it "should call sync! of MvSalesforceObject" do
      mvc_dist_response = MvDistrictSurveyResponse.new
      mvc_dist_response['Name'] = "test user"
      mvc_dist_response['School'] = "school a"
      mv_salesforce_object = MvSalesforceObject.new
      SalesforceObjectFactory.should_receive(:create).with('Monitoring_Visit__c').and_return(mv_salesforce_object)
      mv_salesforce_object.should_receive(:sync!)
      mvc_dist_response.sync!
    end
  end
end