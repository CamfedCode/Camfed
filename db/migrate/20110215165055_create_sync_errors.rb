class CreateSyncErrors < ActiveRecord::Migration
  def self.up
    create_table :sync_errors do |t|
      t.integer :import_history_id
      t.string :salesforce_object
      t.string :raw_request
      t.string :raw_response

      t.timestamps
    end
  end

  def self.down
    drop_table :sync_errors
  end
end
