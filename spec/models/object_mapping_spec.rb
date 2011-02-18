require 'spec_helper'

describe ObjectMapping do
  it {should have_many :field_mappings }
  it {should belong_to :survey }
  it {should validate_presence_of :salesforce_object_name }
  
  describe 'build_unmapped_field_mappings' do
    before(:each) do
      field_mapping = FieldMapping.new(:field_name => 'a_field', :question_name => 'a_question')
      @object_mapping = ObjectMapping.new
      @object_mapping.salesforce_object_name = 'MonitoringVisit'
      @object_mapping.field_mappings << field_mapping
      sf_object = ''
      Salesforce::Base.should_receive(:where).with(:name => 'MonitoringVisit').and_return([sf_object])
      unmapped_field = Salesforce::Field.new('b_field')
      sf_object.should_receive(:salesforce_fields).and_return([unmapped_field])
    end
    
    it 'should build field_mappings for unmapped fields' do
      @object_mapping.field_mappings.should have(1).things
      @object_mapping.build_unmapped_field_mappings      
      @object_mapping.field_mappings.should have(2).things
      @object_mapping.field_mappings.last.field_name.should == 'b_field'
      @object_mapping.field_mappings.last.new_record?.should be true
    end
  end
  
  describe 'deep_clone' do
    before(:each) do
      @object_mapping = ObjectMapping.new(:survey_id => 1, :salesforce_object_name => 'object_a')
      cloned = @object_mapping.clone
      @object_mapping.should_receive(:clone).and_return(cloned)
    end
    it 'should call clone and set survey_id to nil' do
      cloned_mapping = @object_mapping.deep_clone
      cloned_mapping.survey_id.should == nil
    end
    
    it 'should call deep_clone on for each field mapping' do
      field_mappings = []
      @object_mapping.field_mappings = field_mappings
      field_mappings.each{|field_mapping| field_mapping.should_receive(:deep_clone).and_return(field_mapping)}
      cloned_mapping = @object_mapping.deep_clone
    end 
  end
  
end