require 'spec_helper'

describe ImportHistory do
  before(:each) do
    @import_history = ImportHistory.new({:survey_id => "1", :survey_response_id => "2", :survey_name => "a survey"})
  end
  
  it "should be valid" do
    @import_history.should be_valid
  end
  
  it 'should require survey_id' do
    @import_history.survey_id = nil
    @import_history.should_not be_valid
  end

  it 'should require survey_response_id' do
    @import_history.survey_response_id = nil
    @import_history.should_not be_valid
  end

  it 'should require survey_name' do
    @import_history.survey_name = nil
    @import_history.should_not be_valid
  end
  
end
