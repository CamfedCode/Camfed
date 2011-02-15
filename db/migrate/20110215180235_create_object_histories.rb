class CreateObjectHistories < ActiveRecord::Migration
  def self.up
    create_table :object_histories do |t|
      t.integer :import_history_id
      t.string :salesforce_id
      t.string :salesforce_object

      t.timestamps
    end
  end

  def self.down
    drop_table :object_histories
  end
end
