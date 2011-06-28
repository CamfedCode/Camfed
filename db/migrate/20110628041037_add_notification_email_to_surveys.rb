class AddNotificationEmailToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :notification_email, :string
    
    EpiSurveyor::Survey.all.each do |survey|
      survey.notification_email = Configuration.instance.notify_email
      survey.save!
    end
    
    remove_column :configurations, :notify_email 
    
  end

  def self.down
    remove_column :surveys, :notification_email    
    add_column :configurations, :notify_email, :string 
  end
end
