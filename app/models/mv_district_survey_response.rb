class MvDistrictSurveyResponse < SurveyResponse
  def sync!
    sf_objects = []
    sales_force_to_epi_surveyor_mapping.each_pair do |sales_force_object_name, mapping|
      sales_force_object = SalesForceObject.new
      sales_force_object.name = sales_force_object_name
      mapping.each_pair do |field_name, question|
        sales_force_object[field_name] = self[question]
      end
      sales_force_object.sync!
    end
  end
  
  def sales_force_to_epi_surveyor_mapping
    {
      'Monitoring_Visit__c' =>
        {
          'Date__c' => 'Date',
          'Monitor__c' => 'Name',
          'Visiting_structure__c' => 'Structure',
          'School__c' => 'School'
        }
    }
  end
end