require "spec_helper"

describe Dictionary do
   before(:each) do
     REDIS.FLUSHDB
     @translations = {"Shule ya Msingi"=>"Primary", "Shule ya Sekondari ya Kawaida" => "Secondary",
                      "Shule ya Sekondari ya Juu" => "High", "Muhula wa 1" => "Term 1", "Muhula wa 2" => "Term 2"}
   end
  describe "save translations" do
  it "should save translation hash to redis database" do
    Dictionary.save(@translations)
    REDIS.keys.count.should == @translations.keys.length
    REDIS.get("Shule ya Msingi").should == @translations["Shule ya Msingi"]
  end
  end
  describe "get translations as hash"do
    it "should get all the saved translations from the redis database" do
      Dictionary.save(@translations)
      key_value_hash= Dictionary.get_all_translations
      key_value_hash.keys.length.should == @translations.keys.length
      key_value_hash["Shule ya Msingi"].should == @translations["Shule ya Msingi"]
      key_value_hash["Muhula wa 1"].should == @translations["Muhula wa 1"]
    end
  end
end