module EpiSurveyor
  module Dependencies
    
    module ClassMethods
      def auth
        @@auth ||= {
          :username => Configuration.instance.epi_surveyor_user, 
          :accesstoken => Configuration.instance.epi_surveyor_token
        }
      end
      
      def auth=(value)
        @@auth=value
      end

      def headers
        @@headers ||= {'Content-Type' => 'application/x-www-form-urlencoded'}
      end
    end
  
  end
end