class ChangeIsLookupToType < ActiveRecord::Migration
  def self.up
    FieldMapping.all.each do |field_mapping|
      field_mapping.lookup_type = field_mapping.is_lookup? ? 'Lookup' : 'Question'
      field_mapping.save!
    end
    
    remove_column :field_mappings, :is_lookup
  end

  def self.down
    add_column :field_mappings, :is_lookup, :boolean
    
    FieldMapping.all.each do |field_mapping|
      field_mapping.is_lookup = field_mapping.lookup?
      field_mapping.save!
    end
  end
end
