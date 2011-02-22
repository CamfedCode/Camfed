class Configuration < ActiveRecord::Base
  validates :epi_surveyor_url, :presence => true
  validates :epi_surveyor_user, :presence => true
  validates :epi_surveyor_token, :presence => true
  validates :salesforce_url, :presence => true
  validates :salesforce_user, :presence => true
  validates :salesforce_token, :presence => true
  
  after_save do
    self.class.refresh
  end
  
  def self.instance
    @@configuration ||= (Configuration.first || Configuration.new)
  end
  
  def self.refresh
    @@configuration = Configuration.first
  end
  
  def self.instance=(new_instance)
    @@configuration = new_instance
  end
  
end
