class AddPredefinedValueToFieldMappings < ActiveRecord::Migration
  def self.up
    add_column :field_mappings, :predefined_value, :string
    add_column :field_mappings, :lookup_type, :string    
  end

  def self.down
    remove_column :field_mappings, :predefined_value
    remove_column :field_mappings, :lookup_type    
  end
end
