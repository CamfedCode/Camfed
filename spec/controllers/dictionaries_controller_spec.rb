require 'spec_helper'
require 'controllers/authentication_helper'

describe DictionariesController do

  before(:each) do
    sign_on
    @file = fixture_file_upload("/files/test_translations.csv",'text/csv')
    @non_csv_file = fixture_file_upload("/notifier/sync_email",'text/csv')
  end

  describe 'upload' do

  it "should read the uploaded CSV and save the translations" do
    translation_hash = {"Shule ya Msingi"=>"Primary", "Shule ya Sekondari ya Kawaida"=>"Secondary",
                        "Shule ya Sekondari ya Juu"=>"High", "Muhula wa 1"=>"Term 1", "Muhula wa 2"=>"Term 2",
                        "Malezi na Ushauri Nasaha"=>"Guidance and COunselling", "Ulinzi wa Mtoto"=>"Child Protection",
                        "Uhamasishaji wa Jamii"=>"Community Mobilisation", "Afya ya Uzazi"=>"Reproducitve Health",
                        "Maendeleo ya Mtoto"=>"Child Development", "Mengineyo"=>"Other", "blank value"=>""}
    Dictionary.should_receive(:save).with(translation_hash)
    post :upload , :file =>@file
    flash[:notice].should == "Translations uploaded successfully"
  end

  it 'should flash error if file is not uploaded' do
    post :upload
    flash[:error].should == "Upload a valid CSV file"
  end

  it 'should flash error if uploaded file is not in CSV format' do
    post :upload, :file => @non_csv_file
    flash[:error].should == "Upload a valid CSV file"
  end
  end

  describe 'index' do
    it "should fetch all keys and values from translations database" do
      Dictionary.should_receive(:get_all_translations)
      post :index
    end

    it "should return all translations in a csv file" do
      translation_hash = {"Shule ya Msingi"=>"Primary", "Shule ya Sekondari ya Kawaida"=>"Secondary"}
      translation_file = "English,Swahili\nPrimary,Shule ya Msingi\nSecondary,Shule ya Sekondari ya Kawaida\n"
      Dictionary.should_receive(:get_all_translations).and_return(translation_hash)
      controller.stub!(:render)
      controller.should_receive(:send_data).with(translation_file, :type => "text/csv; header=present",
                                                 :disposition => "attachment;filename=translations.csv")
      post :index, :format => "csv"
      assert_response(:success)
    end

    it "should return only translation heading if translations are not present " do
      translation_hash = {}
      translation_file = "English,Swahili\n"
      Dictionary.should_receive(:get_all_translations).and_return(translation_hash)
      controller.stub!(:render)
      controller.should_receive(:send_data).with(translation_file, :type => "text/csv; header=present",
                                                 :disposition => "attachment;filename=translations.csv")
      post :index, :format => "csv"
      assert_response(:success)

    end
  end

  describe 'sample_download' do
    it "should respond with success if sample_csv exists" do
      get :sample_download
      assert_response(:success)
    end
  end
end
