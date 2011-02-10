class ImportHistory < ActiveRecord::Base
  belongs_to :survey
  
  validates :survey_id, :presence => true
  validates :survey_name, :presence => true
  validates :survey_response_id, :presence => true
  
  
end
