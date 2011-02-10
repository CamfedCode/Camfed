class ObjectMappingsController < ApplicationController
  def new
    @survey = EpiSurveyor::Survey.find(params[:survey_id])
    @sf_object_types = ['MonitoringVisit', 'FinancialAccountability', 'Contact', 'Structure']
    @object_mapping = @survey.object_mappings.build
  end
  
  def create
    @object_mapping = ObjectMapping.where(params[:object_mapping]).first || ObjectMapping.new(params[:object_mapping])
    if @object_mapping.save
      redirect_to new_object_mapping_field_mapping_path(@object_mapping)
    end
  end
  
  def update
    @object_mapping = ObjectMapping.find(params[:id])
    if @object_mapping.update_attributes(sanitized_params)
      flash[:notice] = "Success"
    else
      flash[:error] = "Failed. See log."
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