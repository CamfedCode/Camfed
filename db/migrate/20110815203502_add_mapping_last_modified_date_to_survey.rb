class AddMappingLastModifiedDateToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :mapping_last_modified_at, :datetime
  end

  def self.down
    remove_column :surveys, :mapping_last_modified_at
  end
end