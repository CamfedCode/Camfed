class ImportHistory < ActiveRecord::Base
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey'
  has_many :sync_errors, :dependent => :destroy
  has_many :object_histories, :class_name => 'Salesforce::ObjectHistory', :dependent => :destroy
  
  validates :survey_id, :presence => true
  validates :survey_response_id, :presence => true
  
  default_scope :order => 'import_histories.created_at DESC'

  def status
    return 'Success' if sync_errors.blank?
    return 'Incomplete' if object_histories.present?
    'Failed'
  end

  def self.get_by_status(survey_id, status)

    condition =  { }
    condition =  {:survey_id => survey_id } if not survey_id.nil?

    filter = lambda {|history| true }
    filter = lambda {|history| history.sync_errors.blank? }  if status=="Success"
    filter = lambda {|history| !history.sync_errors.blank? } if status=="Failure"
    #:conditions => {:survey_id => survey_id }

    ImportHistory.all(:include => "sync_errors",
                      :conditions => condition
    )
    .select{|history| filter.call(history) }

  end
end
