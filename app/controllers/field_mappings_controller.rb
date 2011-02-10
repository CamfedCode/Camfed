class FieldMappingsController < ApplicationController
  def new
    @object_mapping = ObjectMapping.find(params[:object_mapping_id])
    @fields = Salesforce::ObjectFactory.create(@object_mapping.sf_object_type).fields
    @questions = @object_mapping.survey.questions
  end
  
  def create
  end
end