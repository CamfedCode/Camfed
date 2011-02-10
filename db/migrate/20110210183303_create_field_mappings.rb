class CreateFieldMappings < ActiveRecord::Migration

  def self.up
    create_table :field_mappings do |t|
      t.references :object_mapping
      t.string :field_name
      t.string :question_name
    end
  end

  def self.down
    drop_table :field_mappings
  end

end
