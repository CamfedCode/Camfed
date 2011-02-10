require 'spec_helper'

describe FieldMapping do
  it {should belong_to :object_mapping }
  it {should validate_presence_of :field_name }
  it {should validate_presence_of :question_name }
end