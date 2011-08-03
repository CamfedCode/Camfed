class SyncError < ActiveRecord::Base
  validates :salesforce_object, :presence => true
  
  def to_s
    "SyncError: Salesforce sync error. Salesforce Object:#{salesforce_object} Request:#{raw_request} Response:#{raw_response}"
  end

end
