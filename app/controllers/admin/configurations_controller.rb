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
    
    
  end
end