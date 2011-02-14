require "spec_helper"

describe EpiSurveyor::SurveyResponse do
  
  describe 'find_all_by_survey' do
    before(:each) do
      @survey = EpiSurveyor::Survey.new
      @survey.id = 1
      @survey.name = 'Mv-Dist-Info'
      # configuration = Configuration.new
      # Configuration.stub!(:instance).and_return(configuration)
    end
    
    it 'should return empty when none found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return(nil)
      EpiSurveyor::SurveyResponse.find_all_by_survey(@survey).should == []
    end
    
    it 'should return empty when surveydatalist is empty' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => nil)
      EpiSurveyor::SurveyResponse.find_all_by_survey(@survey).should == []
    end
    
    it 'should return empty when none found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => nil})
      EpiSurveyor::SurveyResponse.find_all_by_survey(@survey).should == []
    end

    it 'should return survey response when only one found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => {'Id' => 1}})
      expected_survey_response = EpiSurveyor::SurveyResponse.new
      expected_survey_response.id = 1
      respones = EpiSurveyor::SurveyResponse.find_all_by_survey(@survey)
      respones.length.should == 1
      expected_survey_response.should == respones.first
    end
    
    it 'should return survey response when multiple are found' do
      EpiSurveyor::SurveyResponse.should_receive(:post).and_return('SurveyDataList' => {'SurveyData' => [{'Id' => 1}, {'Id' => 2}]})
      first_survey_response = EpiSurveyor::SurveyResponse.new
      first_survey_response.id = 1
      second_survey_response = EpiSurveyor::SurveyResponse.new
      
      second_survey_response.id = 2

      respones = EpiSurveyor::SurveyResponse.find_all_by_survey(@survey)
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
    describe 'when it is not synced' do
      before(:each) do
        survey = EpiSurveyor::Survey.new
        survey.id = 1
        survey.name = 'Mv-Dist-Info'
        
        
        @response = EpiSurveyor::SurveyResponse.new
        @response['Name'] = "test user"
        @response['School'] = "school a"
        @response.id = "2"
        @response.survey = survey
        @response.should_receive(:synced?).and_return(false)
        @mv_salesforce_object = Salesforce::MonitoringVisit.new
        @mv_salesforce_object.should_receive(:sync!)
      
        Salesforce::ObjectFactory.should_receive(:create)
          .with('Monitoring_Visit__c').and_return(@mv_salesforce_object)
        
        @mapping = ObjectMapping.new
        @mapping.sf_object_type = 'Monitoring_Visit__c'
        @mapping.field_mappings.build(:field_name => 'School__c', :question_name => 'School')
      end
    
      it "should call sync! of Monitoring Visit" do
        @response.sync!([@mapping])
      end
    
      it 'should create a new import_history' do
        @response.sync!([@mapping])
        ImportHistory.where(:survey_id => "1", :survey_response_id => "2").first.should_not be nil
      end
      
      it 'should return import_history' do
        @response.sync!([@mapping]).is_a?(ImportHistory).should be true
      end
            
    end
    
    it 'should return if already synced' do
      Salesforce::ObjectFactory.should_not_receive(:create)
      mapping = {'Monitoring_Visit__c' => {:School__c => 'School'}}
      response = EpiSurveyor::SurveyResponse.new
      response.should_receive(:synced?).and_return(true)
      response.sync!(mapping)
    end
    
    it 'should dump errors into import histories if there is any' do
      response = EpiSurveyor::SurveyResponse.new
      sf_object = ''
      survey = EpiSurveyor::Survey.new(:name => 'a_survey', :id => '1')
      response.survey = survey
      response.id = '2'
      
      response.should_receive(:salesforce_object).with('mapping').and_return(sf_object)
      response.should_receive(:salesforce_object).with('mapping 2').and_return(sf_object)
      sf_object.should_receive(:sync!).exactly(2).times.and_raise('Error message')
      response.sync!(['mapping', 'mapping 2'])
      ImportHistory.first.error_message.should == 'Error message AND Error message'
    end
  end
  
  # after(:each) do
  #     Configuration.reset
  #   end
  #   
end
      