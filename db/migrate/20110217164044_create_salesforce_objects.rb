class CreateSalesforceObjects < ActiveRecord::Migration
  def self.up
    create_table :salesforce_objects do |t|
      t.string :name
      t.string :label
      t.boolean :display
      t.timestamps
    end
  end

  def self.down
    drop_table :salesforce_objects
  end
end
