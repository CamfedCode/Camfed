class CreateSmsResponses < ActiveRecord::Migration
  def self.up
    create_table :sms_responses do |t|
      t.string :sms_id
      t.text :properties

      t.timestamps
    end
  end

  def self.down
    drop_table :sms_responses
  end
end
