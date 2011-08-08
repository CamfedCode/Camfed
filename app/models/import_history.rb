class ImportHistory < ActiveRecord::Base
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey'
  has_many :sync_errors, :dependent => :destroy
  has_many :object_histories, :class_name => 'Salesforce::ObjectHistory', :dependent => :destroy
  
  validates :survey_id, :presence => true
  validates :survey_response_id, :presence => true
  
  default_scope :order => 'import_histories.created_at DESC'
  scope :survey_scope, lambda { |survey_id|
    where("import_histories.survey_id = ?", survey_id)
  }
  scope :date_range_scope, lambda {|start_date,end_date|
     where("import_histories.created_at between ? AND ?", start_date, end_date)
  }

  def status
    return 'Success' if sync_errors.blank?
    return 'Incomplete' if object_histories.present?
    'Failed'
  end

  def self.get_by_filter(survey_id, status,start_date,end_date)

    end_date = end_date.to_time.advance(:days => 1).to_date unless end_date.nil?

    query_scope = ImportHistory.scoped({})
    query_scope = query_scope.where("import_histories.created_at between ? AND ?", start_date, end_date)   unless start_date.nil? or end_date.nil?
    query_scope = query_scope.where("import_histories.survey_id = ?", survey_id) unless survey_id.nil?

    filter = lambda {|history| true }
    filter = lambda {|history| history.sync_errors.blank? }  if status=="Success"
    filter = lambda {|history| !history.sync_errors.blank? } if status=="Failed"

    query_scope.all(:include => "sync_errors")
   .select{|history| filter.call(history) }

  end
end
