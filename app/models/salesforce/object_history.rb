module Salesforce
  class ObjectHistory < ActiveRecord::Base
    validates :salesforce_object, :presence => true
    validates :salesforce_id, :presence => true
    
    def url
      parts = URI.split(Configuration.instance.salesforce_browse_url)
      URI.join("#{parts[0]}://#{parts[2]}", salesforce_id).to_s
    end
  end
end
