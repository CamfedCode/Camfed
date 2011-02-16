class ObjectMappingsController < AuthenticatedController
  
  def modify
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    @sf_object_types = ['MonitoringVisit', 'FinancialAccountability', 'Contact', 'Structure']
    @object_mapping = @survey.object_mappings.build
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings', survey_mappings_path(@survey)
    add_crumb 'Modify'
  end
  
  def create
    if params[:object_mapping].blank? || params[:object_mapping][:sf_object_type].blank?
      flash[:error] = 'Please select a salesforce object to proceed'
      redirect_to modify_survey_object_mappings_path(params[:survey_id])
      return
    end
    
    @object_mapping = ObjectMapping.where(params[:object_mapping]).first || ObjectMapping.new(params[:object_mapping])
    if @object_mapping.save
      redirect_to new_object_mapping_field_mapping_path(@object_mapping)
    else
      flash[:error] = "There was an error in saving the Object Mapping. Please see log file."
      logger.error "There was an error in saving the Object Mapping because of #{@object_mapping.errors.inspect}"
      redirect_to modify_survey_object_mappings_path(params[:survey_id])
    end
  end
  
  def update
    @object_mapping = ObjectMapping.find(params[:id])
    if @object_mapping.update_attributes(sanitized_params)
      flash[:notice] = "Successfully saved the mappings."
    else
      flash[:error] = "The mapping was not saved. Please check log file for more."
      logger.error "Error in saving mapping " + @object_mapping.errors.inspect
    end
    redirect_to survey_mappings_path(@object_mapping.survey_id)
  end
  
  private
  def sanitized_params
    new_params = params[:object_mapping]
    params[:object_mapping][:field_mappings_attributes].each_pair do |key, value|
      new_params[:field_mappings_attributes].delete(key) if value[:question_name].blank?
    end
    new_params
  end
  
  
end 