require "spec_helper"

describe EpiSurveyor::Dependencies do
  
  before(:each) do
    SampleEpiSurveyorClass.auth = nil
  end

  describe 'auth' do
    it 'should get the values from configuration' do
      configuration = Configuration.new(:epi_surveyor_user => 'a', :epi_surveyor_token => 'b')
      Configuration.should_receive(:instance).exactly(2).times.and_return(configuration)
      SampleEpiSurveyorClass.auth.should == {:username => 'a', :accesstoken => 'b'}
    end
  end
  
  describe 'headers' do
    it 'should set headers' do
      expected_headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
      assert_equal(expected_headers, SampleEpiSurveyorClass.headers)
    end
  end
  
  describe 'base_url' do
    it 'should get the uri from the config' do
      #TODO fill up the body
    end
  end
  
  after(:each) do
    SampleEpiSurveyorClass.auth = nil
  end
  
end


class SampleEpiSurveyorClass
  extend EpiSurveyor::Dependencies::ClassMethods
end
