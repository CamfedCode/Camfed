require 'csv'
module CSVDataExtractor

  def parse_csv(filename)
    translation_hash = {}
    csv_contents = CSV.parse(filename, {:headers => true})
    csv_contents.each do |col|
      col[0] = "" if col[0].nil? #empty value if the value is not specified for a key
      translation_hash[col[1].strip] = col[0].strip if !col[1].nil?
    end
    translation_hash
  end
end
