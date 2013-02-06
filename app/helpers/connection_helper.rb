module ConnectionHelper
  def self.check_connection_with_epi (url, auth_credentials)

    base_uri = url+"/api/surveys"
    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
    response = HTTParty.post(base_uri, :body => auth_credentials, :headers => headers)

    if(response.nil? or response['error'].present?)
      Rails.logger.info ("Test connection with EPI failed. Response: "+ response.to_s)
      return "NOT OK"
    else
      Rails.logger.info ("Test connection with EPI passed. Response: "+ response.to_s)
      return "OK"
    end
  end

end
