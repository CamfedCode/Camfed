class AlterDataTypeOfSurveyId < ActiveRecord::Migration
  def self.up
    change_column :import_histories, :survey_id, :integer
  end

  def self.down
    change_column :import_histories, :survey_id, :string
  end
end
