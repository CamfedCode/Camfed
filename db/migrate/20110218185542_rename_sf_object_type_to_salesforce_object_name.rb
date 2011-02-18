class RenameSfObjectTypeToSalesforceObjectName < ActiveRecord::Migration
  def self.up
    rename_column :object_mappings, :sf_object_type, :salesforce_object_name
  end

  def self.down
    rename_column :object_mappings, :salesforce_object_name, :sf_object_type
  end
end
