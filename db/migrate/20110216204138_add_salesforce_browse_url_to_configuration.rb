class AddSalesforceBrowseUrlToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configurations, :salesforce_browse_url, :string
  end

  def self.down
    remove_column :configurations, :salesforce_browse_url
  end
end
