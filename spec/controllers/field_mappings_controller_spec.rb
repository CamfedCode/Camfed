require 'spec_helper'
require 'controllers/authentication_helper'

describe FieldMappingsController do
  before(:each) do
    sign_on
  end

  describe 'new' do
    let(:object_mapping) { stub_model ObjectMapping, survey: survey, salesforce_object_name: 'MonitoringVisit' }
    let(:survey) { stub_model EpiSurveyor::Survey, questions: [question] }
    let(:question) { stub 'question', name: 'name' }

    it 'should populate object mapping and questions' do
      ObjectMapping.should_receive(:find).with(2).and_return object_mapping
      object_mapping.should_receive :build_unmapped_field_mappings
      survey.should_receive(:unmapped_questions).and_return [question]

      get :new, :object_mapping_id => 2

      response.should be_success
      assigns[:object_mapping].should == object_mapping
      assigns[:questions].should == [question]
      assigns[:questions_for_select].should == [['name', 'name']]
      assigns[:unmapped_questions].should == ['name']
    end
  end

  describe 'destroy' do
    before(:each) do
      @field_mapping = FieldMapping.create(:field_name => 'a_field', :question_name => 'a_question')
      FieldMapping.should_receive(:find).with(@field_mapping.id).and_return(@field_mapping)
      object_mapping = ''
      @field_mapping.should_receive(:object_mapping).twice.and_return(object_mapping)
      object_mapping.should_receive(:touch)
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
end

  describe 'destroy error' do  
    it 'should set the flash error when there is an error' do
      @field_mapping = FieldMapping.create(:field_name => 'a_field', :question_name => 'a_question')
      FieldMapping.should_receive(:find).with(@field_mapping.id).and_return(@field_mapping)
      object_mapping = ''
      @field_mapping.should_receive(:object_mapping).and_return(object_mapping)
      object_mapping.should_receive(:survey_id).and_return(1)
      @field_mapping.should_receive(:destroy).and_return(false)
      delete :destroy, :id => @field_mapping.id
      flash[:error].should_not be nil
    end
  end

  describe 'update' do
    let(:field_mapping) { stub_model FieldMapping }

    before do
      FieldMapping.stub!(:find).and_return field_mapping
    end

    it 'should find existing mapping' do
      FieldMapping.should_receive(:find).with 1
      post :update, id: 1, format: :json
    end

    it 'should update mapping from params' do
      field_mapping.should_receive(:update_attributes).with({'key' => 'value'})
      post :update, id: 1, format: :json, field_mapping: {'key' => 'value'}
    end

    it 'should return unprocessable_entity if invalid update' do
      field_mapping.stub!(:update_attributes).and_return false
      post :update, id: 1, format: :json, field_mapping: {'key' => 'value'}
      response.status.should == 422
    end

    it 'should render errrs if invalid update' do
      errors = {'field' => 'error'}
      field_mapping.stub!(:update_attributes).and_return false
      field_mapping.stub!(:errors).and_return errors
      post :update, id: 1, format: :json, field_mapping: {'key' => 'value'}
      response.body.should == errors.to_json
    end
  end
end