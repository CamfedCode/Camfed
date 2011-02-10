class FieldMapping < ActiveRecord::Base
  belongs_to :object_mapping
  validates :field_name, :presence => true
  validates :question_name, :presence => true
end