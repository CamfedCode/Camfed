class CreateSmsResponses < ActiveRecord::Migration
  def self.up
    create_table :sms_responses do |t|
      t.string :sms_id
      t.string :date_sent
      t.string :message_body
      t.string :sent_to
      t.string :price

      t.timestamps
    end
  end

  def self.down
    drop_table :sms_responses
  end
end

