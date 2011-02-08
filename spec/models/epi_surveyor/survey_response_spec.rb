require "spec_helper"

describe EpiSurveyor::SurveyResponse do
  
  describe 'find_all_by_survey_id' do
    it 'should return empty when none found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return(nil)
      EpiSurveyor::SurveyResponse.find_all_by_survey_id(1).should == []
    end
    
    it 'should return empty when surveydatalist is empty' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => nil)
      EpiSurveyor::SurveyResponse.find_all_by_survey_id(1).should == []
    end
    
    it 'should return empty when none found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => nil})
      EpiSurveyor::SurveyResponse.find_all_by_survey_id(1).should == []
    end

    it 'should return survey response when only one found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => {'Id' => 1}})
      expected_survey_response = EpiSurveyor::SurveyResponse.new
      expected_survey_response.id = 1
      respones = EpiSurveyor::SurveyResponse.find_all_by_survey_id(1)
      respones.length.should == 1
      expected_survey_response.should == respones.first
    end
    
    it 'should return survey response when multiple are found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => [{'Id' => 1}, {'Id' => 2}]})
      first_survey_response = EpiSurveyor::SurveyResponse.new
      first_survey_response.id = 1
      second_survey_response = EpiSurveyor::SurveyResponse.new
      
      second_survey_response.id = 2

      respones = EpiSurveyor::SurveyResponse.find_all_by_survey_id(1)
      respones.length.should == 2
      first_survey_response.should == respones.first
      second_survey_response.should == respones.last
    end
  end
  
  describe '==' do
    it "should be equal to another when they have same id" do
      one_response = EpiSurveyor::SurveyResponse.new
      one_response.id = 1
      
      other_response = EpiSurveyor::SurveyResponse.new
      other_response.id = 1
      
      other_response.should == one_response
    end
  end
  
  describe 'from_hash' do
    it "should create the questions and answers from hash" do
      survey_response = EpiSurveyor::SurveyResponse.from_hash({'Id' => 1, 
                        'UserId' => 'test@camfed.org', 'School' => 'School B'})
      survey_response.id.should == 1
      survey_response.question_answers.length.should == 3
      survey_response['Id'].should == 1      
      survey_response['UserId'].should == 'test@camfed.org'
      survey_response['School'].should == 'School B'
      
    end
  end
  
  describe '[]' do
    it "should set/get a question answer" do
      survey_response = EpiSurveyor::SurveyResponse.new
      survey_response['Name'] = 'test user'
      survey_response['Name'].should == 'test user'
    end
  end
  
  describe 'sync!' do
    it "should call sync! of Monitoring Visit" do
      mvc_dist_response = EpiSurveyor::SurveyResponse.new
      mvc_dist_response['Name'] = "test user"
      mvc_dist_response['School'] = "school a"
      mv_salesforce_object = Salesforce::MonitoringVisit.new
      Salesforce::ObjectFactory.should_receive(:create).with('Monitoring_Visit__c').and_return(mv_salesforce_object)
      mapping = {'Monitoring_Visit__c' => {:School__c => 'School'}}
      mv_salesforce_object.should_receive(:sync!)
      mvc_dist_response.sync!(mapping)
    end
  end
  
end
      