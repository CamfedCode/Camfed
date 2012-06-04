class DictionariesController < AuthenticatedController
  include CSVDataExtractor

  def index
    @all_translations = Dictionary.get_all_translations
    respond_to do|format|
      format.html do
        add_crumb "Dictionary"
      end
      format.csv do
        csv_file = generate_csv
        send_data csv_file, :type => 'text/csv; header=present',
                  :disposition => "attachment;filename=translations.csv"
      end
    end

  end

  def show
    add_crumb "Dictionary"
  end

  def upload
    if  !is_filename_valid(params[:file])
      flash[:error] = "Upload a valid CSV file"
      redirect_to dictionaries_path
      return
    end
    csv_file = params[:file].read
    translation_hash = parse_csv(csv_file)
    Dictionary.save(translation_hash)
    add_crumb "Dictionary"
    flash[:notice] = "Translations uploaded successfully"
    redirect_to dictionaries_path

  end

  def sample_download
     send_file("#{Rails.root}/public/static_files/sample_csv.csv", :type =>"text/csv")
  end

  private

  def is_filename_valid(filename)
    filename.blank? ? false : (filename.original_filename.split(".").last == "csv")
  end

  def generate_csv
    CSV.generate do |csv|
      csv << ["English", "Swahili"]
      @all_translations.map { |row| csv << [row[1],row[0]] }
    end
  end
end