require 'spec_helper'

describe Configuration do
  it {should validate_presence_of :epi_surveyor_url}
  it {should validate_presence_of :epi_surveyor_user}
  it {should validate_presence_of :epi_surveyor_token}
  it {should validate_presence_of :salesforce_url}
  it {should validate_presence_of :salesforce_user}
  it {should validate_presence_of :salesforce_token}
  
  it 'should refresh after save' do
    configuration = Configuration.new({
        :epi_surveyor_url => 'https://www.episurveyor.org', 
        :epi_surveyor_user => 'Camfedtest@gmail.com',
        :epi_surveyor_token => 'YUc8UfyeOm3W9GqNSJYs',
        :salesforce_url => 'https://test.salesforce.com/services/Soap/u/20.0',
        :salesforce_user => 'sf_sysadmin@camfed.org.dean',
        :salesforce_token => 'w3stbrookLidRts9sALeXQYTYhYJUvl5wc', 
       })
    
    Configuration.should_receive(:refresh)
    configuration.save
  end
  
  describe 'instance' do
    before(:each) do
      Configuration.refresh
      @configuration = Configuration.new
    end
  
    it 'should retrun the first instance if its there' do
      Configuration.should_receive(:first).and_return(@configuration)
      Configuration.instance.should == @configuration
    end
  
    it 'should return a new instance if none exists' do
      Configuration.should_receive(:new).and_return(@configuration)
      Configuration.instance.should == @configuration
    end
  end
  
  
  after(:each) do
    Configuration.rspec_reset
  end
  
  
end
