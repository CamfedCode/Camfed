module Admin
  class ConfigurationsController < AuthenticatedController

    def edit      
      @configuration = Configuration.instance
      add_crumb 'Settings'
    end
    
    def update
      @configuration = Configuration.instance
      
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'Successfully updated the configuration changes'
        redirect_to root_path
      else
        flash[:error] = 'Could not update the configuration. Please check the log file.'
        logger.error "Failed to update configuration. #{@configuration.errors.inspect}"
        render :edit
      end
      
    end
    
    def create
      @configuration = Configuration.new(params[:configuration])
      
      if @configuration.save
        flash[:notice] = 'Successfully created the configuration changes'
        redirect_to root_path
      else
        flash[:error] = 'Could not create the configuration. Please check the log file.'
        logger.error "Failed to create configuration. #{@configuration.errors.inspect}"
        render :edit
      end
      
    end

    def send_sms
      begin
        sms = Moonshado::Sms.new(params[:number], params[:message])
        deliver_sms = sms.deliver_sms
        logger.info("SMS gateway response was #{deliver_sms}")
        flash[:notice] = 'Successfully sent the sms'
      rescue Exception => error
        logger.error "Error: '#{error}' encountered while trying to send sms with number: #{params[:number]} and message: #{params[:message]}"
        flash[:error] = "Error sending SMS: #{error} "
      end
      redirect_to edit_admin_configuration_path
    end


    def testEpiConnection
      auth = {:username => params[:epiUser],
              :accesstoken => params[:epiToken]}

      status = ConnectionHelper.check_connection_with_epi(params[:epiURL], auth)
      render :json => {status:status}
    end




  end
end