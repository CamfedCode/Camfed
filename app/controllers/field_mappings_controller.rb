class FieldMappingsController < ApplicationController
  add_crumb 'Home', '/'
  def new
    @object_mapping = ObjectMapping.find(params[:object_mapping_id])
    @object_mapping.build_unmapped_field_mappings
    @questions = @object_mapping.survey.questions
    add_crumb 'Surveys', surveys_path
    add_crumb 'Mappings', survey_mappings_path(@object_mapping.survey_id)
    add_crumb 'New'
  end
  
  
  def destroy
    @field_mapping = FieldMapping.find(params[:id])
    
    if @field_mapping.destroy
      flash[:notice] = "Successfully deleted the field mapping between #{@field_mapping.field_name} and #{@field_mapping.question_name}."      
    else
      flash[:error] = 'Could not delete the field mapping. Please see log file for details.'
    end
    redirect_to survey_mappings_path(@field_mapping.object_mapping.survey_id)
  end
  
end