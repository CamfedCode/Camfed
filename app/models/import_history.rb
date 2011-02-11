class ImportHistory < ActiveRecord::Base
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey'
  
  validates :survey_id, :presence => true
  validates :survey_response_id, :presence => true
  
  default_scope :order => 'import_histories.created_at DESC'
  
end
