require 'csv'
module CSVDataExtractor

  def parse_csv(filename)
    translation_hash = {}
    csv_contents = CSV.parse(filename, {:headers => true})
    case 
    when csv_contents.headers.size == 2
      language = csv_contents.headers[1]
      language_hash = {}
      csv_contents.each do |col|
        col[0] = "" if col[0].nil? #empty value if the value is not specified for a key
        language_hash[col[1].strip] = col[0].strip if !col[1].nil?
      end
      translation_hash[language] = language_hash
    when csv_contents.headers.size > 2
      no_of_languages = csv_contents.headers.size - 1
      language_hash_array = Array.new(no_of_languages)

      csv_contents.each do |col|
        col[0] = "" if col[0].nil? #empty value if the value is not specified for a key
        for i in 1..no_of_languages do
          language_hash_array[i-1] = {} if language_hash_array[i-1].nil?
          language_hash_array[i-1][col[i].strip] = col[0].strip if !col[i].nil?
        end
      end
      for i in 1..no_of_languages do
        translation_hash[csv_contents.headers[i].strip] = language_hash_array[i-1]
      end
    end
    translation_hash
  end
end
