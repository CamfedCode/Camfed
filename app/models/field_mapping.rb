class FieldMapping < ActiveRecord::Base
  belongs_to :object_mapping
  validates :field_name, :presence => true
  validates :question_name, :presence => true
  
  def deep_clone
    cloned_field_mapping = clone
    cloned_field_mapping.object_mapping_id = nil
    cloned_field_mapping
  end
end