require 'spec_helper'

describe EpiSurveyorToSalesforceMapping do
  
  before(:all) do
    test_mapping = File.join(File.dirname(__FILE__), 'test_mapping.yml')
    EpiSurveyorToSalesforceMapping.should_receive(:mapping_file_path).and_return(test_mapping)
    @mappings = EpiSurveyorToSalesforceMapping.mappings
  end
  
  it 'should genereate the hash from the mapping file' do
    @mappings.is_a?(Hash).should be true
  end
  
  it 'should return the mapping for a survey' do
    mapping = EpiSurveyorToSalesforceMapping.find('MV-Dist-Info')
    mapping.is_a?(Hash).should be true
    expected_hash = {
                      :Monitoring_Visit__c => {
                        'Date__c' => 'Date',
                        'Monitor__c' => 'Name'
                      }
                    }
    expected_hash.should == mapping
  end
  
end
