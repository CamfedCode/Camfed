require "spec_helper"

describe "CSV data extractor" do
  include CSVDataExtractor
  describe "parse CSV" do
  it "should return the hash for the parsed CSV file" do
    translation_hash = parse_csv(csv_file)
    translation_hash.keys.length.should == 11
    translation_hash["Shule ya Msingi" ].should == "Primary"
    translation_hash["Maendeleo ya Mtoto" ].should == "Child Development"
    translation_hash["Muhula wa 1" ].should == "Term 1"
  end

   def csv_file
      "English,Swahili
          Primary,Shule ya Msingi
          Secondary,Shule ya Sekondari ya Kawaida
          High,Shule ya Sekondari ya Juu
          Term 1,Muhula wa 1
          Term 2,Muhula wa 2
          Guidance and COunselling,Malezi na Ushauri Nasaha
          Child Protection,Ulinzi wa Mtoto
          Community Mobilisation,Uhamasishaji wa Jamii
          Reproducitve Health,Afya ya Uzazi
          Child Development,Maendeleo ya Mtoto
          Other,Mengineyo"
    end
 end
end