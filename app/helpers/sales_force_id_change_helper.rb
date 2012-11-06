require 'csv'

module SalesForceIdChangeHelper
  def self.update_lookup_condition_with_new_ids(object_name)
    id_hash = parse_csv_for_id_change(object_name)
    query_list = Array.new
    id_hash.each do |id_pair|
      old_id = id_pair[0][0,15]
      new_id = id_pair[1]
      fields = FieldMapping.where("lookup_condition like '%" + old_id + "%'")
      fields.each do |field|
        Rails.logger.info("<UPDATE_IDS_TRACE> " + field.object_mapping.survey.name + ", " + field.field_name + ", " + field.lookup_condition)
        new_value = field.lookup_condition.gsub(old_id, new_id)
        field.update_attributes( :lookup_condition => new_value)
        Rails.logger.info("<UPDATE_IDS_TRACE> Old id: " + old_id)
        Rails.logger.info("<UPDATE_IDS_TRACE> Updated lookup condition: " + new_value)
      end
    end
  end

  def self.parse_csv_for_id_change(filename)
	csv_file_name = "./resources/" + filename + ".csv"
	csvFile = File.read(csv_file_name)

	ids_hash = {}
	csv_contents = CSV.parse(csvFile, {:headers => true})
	csv_contents.each { |id_pair|
	  ids_hash[id_pair[0]] = id_pair[1];
	}
	ids_hash
  end

  def self.list_surveys_with_lookup_condition_containing(patterns)
    patterns.each do |pattern|
      fields = FieldMapping.where("lookup_condition like '%" + pattern + "%'")
      fields.each do |field|
         puts "Surveys matching the lookup condition:"
         puts field.object_mapping.survey.name + ", " + field.field_name + ", " + field.lookup_condition
         Rails.logger.info("<UPDATE_IDS_TRACE> " + field.object_mapping.survey.name + ", " + field.field_name + ", " + field.lookup_condition)
      end
    end
  end
end
