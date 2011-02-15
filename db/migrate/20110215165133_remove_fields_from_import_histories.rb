class RemoveFieldsFromImportHistories < ActiveRecord::Migration
  def self.up
    remove_column :import_histories, :survey_name
    remove_column :import_histories, :error_message
    remove_column :import_histories, :is_error
  end

  def self.down
    add_column :import_histories, :survey_name, :string
    add_column :import_histories, :error_message, :string
    add_column :import_histories, :is_error, :boolean
  end
end
