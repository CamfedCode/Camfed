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
        @mv_salesforce_object = Salesforce::Base.new
        
        object_history = Salesforce::ObjectHistory.new(:salesforce_id => '1', :salesforce_object => 'AnObject')
        @mv_salesforce_object.should_receive(:sync!).and_return(object_history)
      
        Salesforce::Base.should_receive(:where).with(:name => 'Monitoring_Visit__c').and_return([@mv_salesforce_object])
        
        @mapping = ObjectMapping.new
        @mapping.salesforce_object_name = 'Monitoring_Visit__c'
        @mapping.field_mappings.build(:field_name => 'School__c', :question_name => 'School')
      end
    
      it "should call sync! of Monitoring Visit" do
        @response.sync!([@mapping])
      end
    
      it 'should create a new import_history' do
        @response.sync!([@mapping])
        ImportHistory.where(:survey_id => "1", :survey_response_id => "2").first.should_not be nil
      end
      
      it 'should return import_history with object history' do
        import_history = @response.sync!([@mapping])
        import_history.is_a?(ImportHistory).should be true
        import_history.object_histories.should have(1).thing
      end
            
    end
    describe 'sync and check for import histories' do
      before (:each) do
        @survey_response = EpiSurveyor::SurveyResponse.new
        @survey_response.question_answers = {'a_question' => 'an answer',
                                             'b_question' => 'b answer',
                                             'c_question' => "c'answer"}
        @survey_response.id = '1'
        @survey = EpiSurveyor::Survey.new(:name => 'a_survey', :id => '1')
        @survey.save!
        @survey_response.survey = @survey
        @object_mapping = ObjectMapping.new(:id => 1, :survey_id => @survey.id, :salesforce_object_name => "School_Termly_Update__c")

      end
      it "synced? should return true if import history exists and sync errors doesnot exist" do
            import_history = ImportHistory.new(:survey_id => @survey.id, :survey_response_id => @survey_response.id)
            import_history.save!
            @survey_response.synced?.should == true
      end

      it "synced? should return false if import history exists and sync errors also exist" do
            import_history = ImportHistory.new(:survey_id => @survey.id, :survey_response_id => @survey_response.id)
            import_history.save!
            sync_error = SyncError.new(:salesforce_object => 'School_Termly_Update__c', :import_history_id => import_history.id)
            sync_error.save!
            @survey_response.synced?.should == false
      end

      it "synced? should return false if import history doesnot exist" do
            @survey_response.synced?.should == false
      end

      it "should delete sync errors if the latest sync! is success" do
        object_history = Salesforce::ObjectHistory.new(:salesforce_id => '1', :salesforce_object => 'AnObject')
        mv_salesforce_object = Salesforce::Base.new
        mv_salesforce_object.should_receive(:sync!).exactly(2).times.and_return(object_history)
        Salesforce::Base.should_receive(:where).exactly(2).times.with(:name => 'School_Termly_Update__c').and_return([mv_salesforce_object])

        @survey_response.sync! [@object_mapping]
        import_history = ImportHistory.where(:survey_id => "1", :survey_response_id => "1").first
        import_history.should_not be nil
        import_history.sync_errors.should be_blank

        import_history.sync_errors << SyncError.new(:salesforce_object => 'AnObject')
        import_history.save!

        @survey_response.sync! [@object_mapping]
        import_history = ImportHistory.where(:survey_id => "1", :survey_response_id => "1").first
        import_history.should_not be nil
        import_history.sync_errors.should be_blank
      end

    end

    it 'should return if already synced' do
      Salesforce::Base.should_not_receive(:where)
      mapping = {'Monitoring_Visit__c' => {:School__c => 'School'}}
      response = EpiSurveyor::SurveyResponse.new
      response.should_receive(:synced?).and_return(true)
      response.sync!(mapping)
    end

    it 'should dump errors into import histories if there is any' do
      response = EpiSurveyor::SurveyResponse.new
      sf_object = ''
      sf_object_2 = ''
      survey = EpiSurveyor::Survey.new(:name => 'a_survey', :id => '1')
      response.survey = survey
      response.id = '2'
      
      #sets up the mapping
      response.should_receive(:salesforce_object).with('mapping').and_return(sf_object)
      response.should_receive(:salesforce_object).with('mapping 2').and_return(sf_object_2)
      
      #sets up the exceptions
      sf_object.should_receive(:sync!).and_raise(SyncException.new(SyncError.new(:salesforce_object => '1')))
      sf_object_2.should_receive(:sync!).and_raise(SyncException.new(SyncError.new(:salesforce_object => '2')))

      import_history = response.sync!(['mapping', 'mapping 2'])
      import_history.sync_errors.should have(2).things
    end
  end
  
  describe 'replace_with_answers' do
    before(:each) do
      @survey_response = EpiSurveyor::SurveyResponse.new
      @survey_response.question_answers = {'a_question' => 'an answer',
                                           'b_question' => 'b answer',
                                           'c_question' => "c'answer"}
    end
    it 'should not replace if there is no token to replace' do
      @survey_response.replace_with_answers('').should == ''
    end

    it 'should replace if there is only one token to replace' do
      @survey_response.replace_with_answers("name=<a_question>").should == "name='an answer'"
    end

    it 'should replace if there are many tokens to replace' do
      @survey_response.replace_with_answers("name=<a_question> and email=<b_question>").should == "name='an answer' and email='b answer'"
    end
    
    it 'should not alter the condition_string' do
      condition_string = "name=<a_question> and email=<b_question>"
      @survey_response.replace_with_answers(condition_string).should == "name='an answer' and email='b answer'"
      condition_string.should == "name=<a_question> and email=<b_question>"
    end

    it 'should handle strings with existing clauses' do
      condition_string = "Name=<a_question> AND District__c='a1BC0000000QBhv'"
      @survey_response.replace_with_answers(condition_string).should == "Name='an answer' AND District__c='a1BC0000000QBhv'"
    end

    it 'should handle apostrophes in the answers' do
      condition_string = "Name=<c_question> AND District__c='a1BC0000000QBhv'"
      @survey_response.replace_with_answers(condition_string).should == "Name='c\\'answer' AND District__c='a1BC0000000QBhv'"
    end

    it 'should handle apostrophes even with many answers' do
      condition_string = "School=<a_question> AND Name=<c_question> AND District__c='a1BC0000000QBhv'"
      @survey_response.replace_with_answers(condition_string).should == "School='an answer' AND Name='c\\'answer' AND District__c='a1BC0000000QBhv'"
    end

    it 'should handle questions nested in answers' do
      # not sure this is a requirement yet
    end
  end
  
  describe 'lookup' do
    it 'should lookup using the field mapping' do
      @survey_response = EpiSurveyor::SurveyResponse.new
      field_mapping = FieldMapping.new(:field_name => 'a_field', :lookup_object_name => 'Contact', :lookup_condition => "name='<name>'")
      @survey_response.should_receive(:replace_with_answers).with(field_mapping.lookup_condition).and_return("name='hello'")
      Salesforce::Base.should_receive(:first_from_salesforce)
                    .with(:Id, field_mapping.lookup_object_name, "name='hello'")
                    .and_return(1)
      @survey_response.lookup(field_mapping).should == 1
    end
  end
  
  describe 'value_for' do
    before(:each) do
      @survey_response = EpiSurveyor::SurveyResponse.new
      @survey_response.question_answers = {'a_question' => 'an answer'}
      @field_mapping = FieldMapping.new(:question_name => 'a_question')
    end
    
    it 'should return the answer when lookup not required' do
      @field_mapping.should_receive(:lookup?).and_return(false)
      @survey_response.value_for(@field_mapping).should == 'an answer'
    end
    
    it 'should call lookup when field_mapping requires lookup' do
      @field_mapping.should_receive(:lookup?).and_return(true)
      @survey_response.should_receive(:lookup).with(@field_mapping).and_return(1)
      @survey_response.value_for(@field_mapping).should == 1
    end
    
    it 'should return predefined value when lookup type is predefined_value' do
      @field_mapping.predefined_value = 'a preset value'
      @field_mapping.should_receive(:predefined_value?).and_return(true)
      @survey_response.value_for(@field_mapping).should == 'a preset value'      
    end
    
  end
  
  describe 'formatted_answer' do
    it 'should not quote if its a valid date' do
      EpiSurveyor::SurveyResponse.new.formatted_answer('2011-03-18').should == "2011-03-18"
    end
    
    it 'should quote non date fields' do
      EpiSurveyor::SurveyResponse.new.formatted_answer('2011-13-18').should == "'2011-13-18'"
    end
    
    it 'should escape answer with a quote' do
      EpiSurveyor::SurveyResponse.new.formatted_answer("h'ello").should == "'h\\'ello'"
    end
    
    it 'should escape answer with a back quote' do
      EpiSurveyor::SurveyResponse.new.formatted_answer("h`ello").should == "'h\\'ello'"
    end
  end
  
end
      
      