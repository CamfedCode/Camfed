require "spec_helper"

describe SurveyResponse do
  describe 'find_all_by_survey_id' do
    it 'should return empty when none found' do
      SurveyResponse.should_receive(:post).and_return(nil)
      SurveyResponse.find_all_by_survey_id(1).should == []
    end
    
    it 'should return empty when surveydatalist is empty' do
      SurveyResponse.should_receive(:post).and_return('SurveyDataList' => nil)
      SurveyResponse.find_all_by_survey_id(1).should == []
    end
    
    it 'should return empty when none found' do
      SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => nil})
      SurveyResponse.find_all_by_survey_id(1).should == []
    end

    it 'should return survey response when only one found' do
      SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => {'Id' => 1}})
      expected_survey_response = SurveyResponse.new
      expected_survey_response.id = 1
      respones = SurveyResponse.find_all_by_survey_id(1)
      respones.length.should == 1
      expected_survey_response.should == respones.first
    end
    
    it 'should return survey response when multiple are found' do
      SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => [{'Id' => 1}, {'Id' => 2}]})
      first_survey_response = SurveyResponse.new
      first_survey_response.id = 1
      second_survey_response = SurveyResponse.new
      
      second_survey_response.id = 2

      respones = SurveyResponse.find_all_by_survey_id(1)
      respones.length.should == 2
      first_survey_response.should == respones.first
      second_survey_response.should == respones.last
    end
    
  end
  
  describe '==' do
    it "should be equal to another when they have same id" do
      one_response = SurveyResponse.new
      one_response.id = 1
      
      other_response = SurveyResponse.new
      other_response.id = 1
      
      other_response.should == one_response
    end
  end
  
  describe 'from_hash' do
    it "should create the questions and answers from hash" do
      survey_response = SurveyResponse.from_hash({'Id' => 1, 
                        'UserId' => 'test@camfed.org', 'School' => 'School B'})
      survey_response.id.should == 1
      survey_response.question_answers.length.should == 3
      survey_response['Id'].should == 1      
      survey_response['UserId'].should == 'test@camfed.org'
      survey_response['School'].should == 'School B'
      
    end
  end
  
end
      