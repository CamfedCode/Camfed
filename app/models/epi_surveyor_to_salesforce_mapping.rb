class EpiSurveyorToSalesforceMapping

  def self.mapping_file_path
    File.join(File.dirname(__FILE__), '..', '..', 'config', 'mapping.yml')
  end
  
  def self.mappings
    @@mappings ||= YAML::load(File.open(mapping_file_path))
  end
  
  def self.find(name)
    mappings[name.to_s].symbolize_keys
  end
end