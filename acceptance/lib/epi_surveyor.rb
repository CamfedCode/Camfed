module EpiSurveyor
  def self.create_survey_file survey_name
    source_directory_path = "#{File.dirname(__FILE__)}/input_files"
    source_file_name = 'test_form'
    source_file_extension = '.svy'
    source_file_path = "#{source_directory_path}/#{source_file_name}#{source_file_extension}"
    required_file_path = "#{source_directory_path}/#{survey_name}#{source_file_extension}"
    FileUtils.cp(source_file_path, required_file_path) unless required_file_path == source_file_path
    return required_file_path
  end

  def self.destroy_survey_file file_path
    FileUtils.rm file_path, :force => true
  end
end