class CreateAddDefaultValueToFieldMapppings < ActiveRecord::Migration
  def self.up
    create_table :add_default_value_to_field_mapppings do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :add_default_value_to_field_mapppings
  end
end
