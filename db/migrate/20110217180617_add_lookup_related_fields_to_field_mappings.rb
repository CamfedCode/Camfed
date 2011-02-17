class AddLookupRelatedFieldsToFieldMappings < ActiveRecord::Migration
  def self.up
    add_column :field_mappings, :lookup_object_name, :string
    add_column :field_mappings, :lookup_condition, :string
  end

  def self.down
    remove_column :field_mappings, :lookup_object_name
    remove_column :field_mappings, :lookup_condition
  end
end
