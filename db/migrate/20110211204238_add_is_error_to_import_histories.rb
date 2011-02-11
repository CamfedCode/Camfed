class AddIsErrorToImportHistories < ActiveRecord::Migration
  def self.up
    add_column :import_histories, :is_error, :boolean
  end

  def self.down
    remove_column :import_histories, :is_error, :boolean    
  end
end
