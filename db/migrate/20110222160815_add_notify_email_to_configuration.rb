class AddNotifyEmailToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configurations, :notify_email, :string
  end

  def self.down
    remove_column :configuration, :notify_email
  end
end
