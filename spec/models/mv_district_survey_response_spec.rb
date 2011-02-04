require "spec_helper"

describe MvDistrictSurveyResponse do
  describe 'sync!' do
    it "should call sync! of MvSalesforceObject" do
      mvc_dist_response = MvDistrictSurveyResponse.new
      mvc_dist_response.sync!
    end
  end
end