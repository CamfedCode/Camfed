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
end