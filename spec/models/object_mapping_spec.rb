require 'spec_helper'

describe ObjectMapping do
  it {should have_many :field_mappings }
  it {should belong_to :survey }
  
  describe 'build_unmapped_field_mappings' do
    before(:each) do
      field_mapping = FieldMapping.new(:field_name => 'a_field', :question_name => 'a_question')
      @object_mapping = ObjectMapping.new
      @object_mapping.sf_object_type = 'MonitoringVisit'
      @object_mapping.field_mappings << field_mapping
      sf_object = ''
      Salesforce::ObjectFactory.should_receive(:create).with('MonitoringVisit').and_return(sf_object)
      unmapped_field = Salesforce::Field.new('b_field')
      sf_object.should_receive(:fields).and_return([unmapped_field])
    end
    
    it 'should build field_mappings for unmapped fields' do
      @object_mapping.field_mappings.should have(1).things
      @object_mapping.build_unmapped_field_mappings      
      @object_mapping.field_mappings.should have(2).things
      @object_mapping.field_mappings.last.field_name.should == 'b_field'
      @object_mapping.field_mappings.last.new_record?.should be true
    end
  end
end