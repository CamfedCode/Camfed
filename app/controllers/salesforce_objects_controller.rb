class SalesforceObjectsController < AuthenticatedController
  def index
    @salesforce_objects = Salesforce::Base.all
    add_crumb 'Salesforce Objects'
  end
  
  def fetch_all
    @salesforce_objects = Salesforce::Base.fetch_all_objects
    flash[:notice] = "Successfully updated the list of all salesforce objects"
    redirect_to salesforce_objects_path
  end
  
  def enable
    set_enabled(true)
  end
  
  def disable
    set_enabled(false)
  end
  
  def show
    @salesforce_object = Salesforce::Base.find(params[:id])
    add_crumb 'Salesforce Objects', salesforce_objects_path
    add_crumb @salesforce_object.label
    respond_to do |format|
      format.html
      format.json{render :json => @salesforce_object.salesforce_fields.to_json }
    end
  end
  
  private
  def set_enabled enabled
    message = enabled ? "enable" : "disable"
        
    @salesforce_object = Salesforce::Base.find(params[:id])
    @salesforce_object.enabled = enabled

    if @salesforce_object.save
      flash[:notice] = "Successfully #{message}d #{@salesforce_object.label}"
    else
      flash[:error] = "Could not #{message} #{@salesforce_object.label} because of #{@salesforce_object.errors.inspect}"
    end
    redirect_to salesforce_objects_path
  end
  
end