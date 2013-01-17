class AddMappingStatusToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :mapping_status, :string, :default => ''

    EpiSurveyor::Survey.all.each do |survey|
      survey.update_mapping_status
    end

  end

  def self.down
    remove_column :surveys, :mapping_status
  end
end

