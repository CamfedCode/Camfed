class EpiSurveyorToSalesforceMapping

  def self.mapping_file_path
    File.join(File.dirname(__FILE__), '..', '..', 'config', 'mapping.yml')
  end
  
  def self.mappings
    @@mappings ||= YAML::load(File.open(mapping_file_path))
  end
  
  def self.find(name)
    puts "name=#{name} mappings keys = #{mappings.keys.join(" ")}"
    mappings[name.to_s].symbolize_keys
  end
end