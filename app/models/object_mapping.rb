class ObjectMapping < ActiveRecord::Base
  has_many :field_mappings
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey'
  
  accepts_nested_attributes_for :field_mappings
  
end