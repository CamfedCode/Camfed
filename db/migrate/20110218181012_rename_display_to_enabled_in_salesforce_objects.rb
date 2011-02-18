class RenameDisplayToEnabledInSalesforceObjects < ActiveRecord::Migration
  def self.up
    rename_column :salesforce_objects, :display, :enabled
  end

  def self.down
    rename_column :salesforce_objects, :enabled, :display
  end
end
