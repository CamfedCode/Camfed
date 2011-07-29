class AddModifiedDatesToMappings < ActiveRecord::Migration
  def self.up
    add_column :field_mappings, :created_at, :datetime
    add_column :field_mappings, :updated_at, :datetime

    FieldMapping.all.each do |field_mapping|
      field_mapping.created_at = DateTime.now
      field_mapping.updated_at = DateTime.now
      field_mapping.save!
    end 

  end

  def self.down
    remove_column :field_mappings, :created_at
    remove_column :field_mappings, :updated_at
  end
end