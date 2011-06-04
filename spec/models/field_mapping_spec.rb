require 'spec_helper'

describe FieldMapping do
  it {should belong_to :object_mapping }
  it {should validate_presence_of :field_name }
  
  describe 'deep_clone' do
    it 'should call clone and set object_mapping_id to nil' do
      field_mapping = FieldMapping.new(:field_name => 'a_field', :question_name => 'a_question', :object_mapping_id => 1)
      deep_cloned = field_mapping.deep_clone
      deep_cloned.object_mapping_id.should == nil
    end
  end
  
  describe 'lookup?' do
    it 'should be true when the value is Lookup' do
      field_mapping = FieldMapping.new :lookup_type => FieldMapping::LOOKUP
      field_mapping.lookup?.should be true
    end
    
    it 'should be false otherwise' do
      field_mapping = FieldMapping.new
      field_mapping.lookup?.should be false
    end
  end
  
  describe 'question?' do
    it 'should be true when the value is Question' do
      field_mapping = FieldMapping.new :lookup_type => FieldMapping::QUESTION
      field_mapping.question?.should be true
    end

    it 'should be false otherwise' do
      field_mapping = FieldMapping.new
      field_mapping.question?.should be false
    end
  end
  
  describe 'predefined_value?' do
    it 'should be true when the value is Lookup' do
      field_mapping = FieldMapping.new :lookup_type => FieldMapping::PREDEFINED_VALUE
      field_mapping.predefined_value?.should be true
    end
    
    it 'should be false otherwise' do
      field_mapping = FieldMapping.new
      field_mapping.predefined_value?.should be false
    end    
  end
  
  
end