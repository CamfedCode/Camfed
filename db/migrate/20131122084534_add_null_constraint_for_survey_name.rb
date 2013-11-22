class AddNullConstraintForSurveyName < ActiveRecord::Migration
  def self.up
    change_column :surveys, :name, :string, :null => false
  end

  def self.down
    change_column :surveys, :name, :string, :null => true
  end
end
