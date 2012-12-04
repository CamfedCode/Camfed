class AddSupportedLanguagesToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configurations, :supported_languages, :string, :default => 'Swahili'
  end

  def self.down
    remove_column :configurations, :supported_languages
  end
end
