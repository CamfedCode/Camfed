class ImportHistory < ActiveRecord::Base
  validates :survey_id, :presence => true
  validates :survey_name, :presence => true
  validates :survey_response_id, :presence => true
  
end
