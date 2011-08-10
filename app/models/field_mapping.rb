class FieldMapping < ActiveRecord::Base
  QUESTION = "Question"
  PREDEFINED_VALUE = "PredefinedValue"
  LOOKUP = "Lookup"
  
  belongs_to :object_mapping, :touch => true
  validates :field_name, :presence => true
  
  def deep_clone
    cloned_field_mapping = clone
    cloned_field_mapping.object_mapping_id = nil
    cloned_field_mapping
  end
  
  def self.lookup_types
    [QUESTION, LOOKUP, PREDEFINED_VALUE]
  end
  
  def lookup?
    lookup_type == LOOKUP
  end
  
  def predefined_value?
    lookup_type == PREDEFINED_VALUE
  end

  def question?
    lookup_type == QUESTION
  end
  
end