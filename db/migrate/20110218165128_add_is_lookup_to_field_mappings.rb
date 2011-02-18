class AddIsLookupToFieldMappings < ActiveRecord::Migration
  def self.up
    add_column :field_mappings, :is_lookup, :boolean
  end

  def self.down
    remove_column :field_mappings, :is_lookup
  end
end
