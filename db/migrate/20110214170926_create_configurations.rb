class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :epi_surveyor_url
      t.string :epi_surveyor_user
      t.string :epi_surveyor_token
      t.string :salesforce_url
      t.string :salesforce_user
      t.string :salesforce_token

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
