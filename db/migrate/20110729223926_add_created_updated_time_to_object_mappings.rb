class AddCreatedUpdatedTimeToObjectMappings < ActiveRecord::Migration
    def self.up
      add_column :object_mappings, :created_at, :datetime
      add_column :object_mappings, :updated_at, :datetime

      ObjectMapping.all.each do |object_mapping|
        object_mapping.created_at = DateTime.now
        object_mapping.updated_at = DateTime.now
        object_mapping.save!
      end 

    end

    def self.down
      remove_column :object_mappings, :created_at
      remove_column :object_mappings, :updated_at
    end
  end
