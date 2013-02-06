module ConnectionHelper
  def self.check_connection_with_epi (url, auth_credentials)

    base_uri = url+"/api/surveys"
    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}

    begin
      response = HTTParty.post(base_uri, :body => auth_credentials, :headers => headers)
    rescue => e
      Rails.logger.info ("Exception occurred. Error message: "+ e.message)
      return "NOT OK"
    end

    if(response.nil? or response.has_key?("error"))
      Rails.logger.info ("Test connection with EPI failed. Response: "+ response.to_s)
      return "NOT OK"
    else
      Rails.logger.info ("Test connection with EPI passed. Response: "+ response.to_s)
      return "OK"
    end
  end

end
