class CreateImportHistories < ActiveRecord::Migration
  def self.up
    create_table :import_histories do |t|
      t.integer :survey_id
      t.string :survey_name
      t.string :survey_response_id
      t.text :error_message
      t.timestamps
    end
  end

  def self.down
    drop_table :import_histories
  end
end
