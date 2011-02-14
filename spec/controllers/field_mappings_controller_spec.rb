require 'spec_helper'
require 'controllers/authentication_helper'

describe FieldMappingsController do
  before(:each) do
    sign_on
  end
  
  describe 'new' do
    it 'should populate object mapping and questions' do

      object_mapping = ObjectMapping.create(:survey_id => 1, :sf_object_type => 'MonitoringVisit')
      object_mapping.should_receive(:build_unmapped_field_mappings)
      ObjectMapping.should_receive(:find).with(object_mapping.id).and_return(object_mapping)


      survey = ''
      object_mapping.should_receive(:survey).and_return(survey)
      survey.should_receive(:questions).and_return([])
      
      get :new, :object_mapping_id => object_mapping.id
      
      response.should be_success
      assigns[:object_mapping].should == object_mapping
      assigns[:questions].should == []
    end
  end
  
  describe 'destroy' do
    before(:each) do
      @field_mapping = FieldMapping.create(:field_name => 'a_field', :question_name => 'a_question')
      FieldMapping.should_receive(:find).with(@field_mapping.id).and_return(@field_mapping)
      object_mapping = ''
      @field_mapping.should_receive(:object_mapping).and_return(object_mapping)
      object_mapping.should_receive(:survey_id).and_return(1)
    end
    
    it 'should delete an existing field_mapping' do
      delete :destroy, :id => @field_mapping.id
      FieldMapping.count.should == 0
    end
    
    it 'should assign the field mappings' do
      delete :destroy, :id => @field_mapping.id
      assigns[:field_mapping].should == @field_mapping
    end
    
    it 'should redirect to mappings' do
      delete :destroy, :id => @field_mapping.id
      response.should redirect_to(survey_mappings_path(1))
    end
    
    it 'should set the flash error when there is an error' do
      @field_mapping.should_receive(:destroy).and_return(false)
      delete :destroy, :id => @field_mapping.id
      flash[:error].should_not be nil
    end
  end
  
end