class SyncException < Exception
  attr_accessor :sync_error
  
  def initialize(sync_error=nil)
    self.sync_error = sync_error
    super sync_error.to_s
  end
end