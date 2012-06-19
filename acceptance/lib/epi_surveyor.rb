module EpiSurveyor
  def self.create_survey_file survey_name, source_file_path="#{File.dirname(__FILE__)}/input_files/test_form.svy"
    raise "Could not locate survey file '#{source_file_path}'" unless File.exists? source_file_path
    temp_directory = File.dirname(source_file_path) + "/temp"
    FileUtils.mkdir(temp_directory) unless File.exists? temp_directory
    required_file_path = temp_directory + '/' + survey_name + File.extname(source_file_path)
    FileUtils.cp(source_file_path, required_file_path) unless required_file_path == source_file_path
    return File.absolute_path required_file_path
  end

  def self.destroy_survey_file file_path
    FileUtils.rm file_path, :force => true
  end
end