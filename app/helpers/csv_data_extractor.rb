require 'csv'
module CSVDataExtractor

  def parse_csv(filename)
    translation_hash = {}
    csv_contents = CSV.parse(filename, {:headers => true})
    csv_contents.each do |row|
      translation_hash[row[1].strip] = row[0].strip
    end
    translation_hash
  end
end