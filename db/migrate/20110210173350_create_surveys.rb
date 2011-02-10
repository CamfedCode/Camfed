class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.string :name
      t.datetime :last_imported_at
      t.timestamps
    end
  end

  def self.down
    drop_table :surveys
  end
end
