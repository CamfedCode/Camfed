class CreateObjectMappings < ActiveRecord::Migration
  def self.up
    create_table :object_mappings do |t|
      t.references :survey
      t.string :sf_object_type
    end
  end

  def self.down
    drop_table :object_mappings
  end
end
