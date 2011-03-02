class ChangeSyncErrorsColumnsToText < ActiveRecord::Migration

  def self.up
    change_column :sync_errors, :raw_request, :text
    change_column :sync_errors, :raw_response, :text    
  end

  def self.down
    change_column :sync_errors, :raw_request, :string
    change_column :sync_errors, :raw_response, :string   
  end
end
