class AddVerifiedByAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :verified_by_admin, :boolean
  end

  def self.down
    remove_column :users, :verified_by_admin
  end
end
