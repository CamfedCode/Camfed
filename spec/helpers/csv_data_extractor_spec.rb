require "spec_helper"

describe "CSV data extractor" do
  include CSVDataExtractor
  describe "parse CSV" do
  it "should return the hash for the parsed CSV file with one translation" do
    translation_hash = parse_csv(csv_file_for_one_language)
    translation_hash.keys.length.should == 1
    translation_hash['Swahili'].keys.length.should == 11
    translation_hash['Swahili']["Shule ya Msingi" ].should == "Primary"
    translation_hash['Swahili']["Maendeleo ya Mtoto" ].should == "Child Development"
    translation_hash['Swahili']["Muhula wa 1" ].should == "Term 1"
  end

  it "should return the hash for the parsed CSV file with two translations" do
    translation_hash = parse_csv(csv_file_for_two_languages)
    translation_hash.keys.length.should == 2
    translation_hash['Swahili'].keys.length.should == 11
    translation_hash['Spanish'].keys.length.should == 11

    translation_hash['Swahili']["Shule ya Msingi" ].should == "Primary"
    translation_hash['Spanish']["SPrimary" ].should == "Primary"
    translation_hash['Swahili']["Maendeleo ya Mtoto" ].should == "Child Development"
    translation_hash['Spanish']["SChild Development" ].should == "Child Development"
    translation_hash['Swahili']["Muhula wa 1" ].should == "Term 1"
    translation_hash['Spanish']["STerm 1"].should == "Term 1"
  end

 def csv_file_for_one_language
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
   def csv_file_for_two_languages
      "English,Swahili,Spanish
          Primary,Shule ya Msingi, SPrimary
          Secondary,Shule ya Sekondari ya Kawaida, SSecondary
          High,Shule ya Sekondari ya Juu, SHigh
          Term 1,Muhula wa 1, STerm 1
          Term 2,Muhula wa 2, STerm 2
          Guidance and COunselling,Malezi na Ushauri Nasaha, SGuidance and Counselling
          Child Protection,Ulinzi wa Mtoto, SChild Protection
          Community Mobilisation,Uhamasishaji wa Jamii, SCommunity Mobilisation
          Reproducitve Health,Afya ya Uzazi, SReproducitve Health
          Child Development,Maendeleo ya Mtoto, SChild Development
          Other,Mengineyo, SOther"
    end
 end
end