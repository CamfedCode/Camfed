require "spec_helper"

describe EpiSurveyor::Question do
  
  describe 'find_all_by_survey' do
    before(:each) do
      @survey = EpiSurveyor::Survey.new
      @survey.id = 1
      @survey.name = 'Mv-Dist-Info'
    end
    
    it 'should return empty when none found' do
      EpiSurveyor::Question.should_receive(:post).and_return(nil)
      EpiSurveyor::Question.find_all_by_survey(@survey).should == []
    end
    
    it 'should return empty when Questions is empty' do
      EpiSurveyor::Question.should_receive(:post).and_return('Questions' => nil)
      EpiSurveyor::Question.find_all_by_survey(@survey).should == []
    end
    
    it 'should return empty when none found' do
      EpiSurveyor::Question.should_receive(:post).and_return('Questions' => {'Question' => nil})
      EpiSurveyor::Question.find_all_by_survey(@survey).should == []
    end

    it 'should return question when only one found' do
      EpiSurveyor::Question.should_receive(:post).and_return('Questions' => {'Question' => {'Id' => 1}})
      expected_question = EpiSurveyor::Question.new
      expected_question.id = 1
      questions = EpiSurveyor::Question.find_all_by_survey(@survey)
      questions.length.should == 1
      expected_question.should == questions.first
    end
    
    it 'should return questions when multiple are found' do
      EpiSurveyor::Question.should_receive(:post).and_return('Questions' => {'Question' => [{'Id' => 1}, {'Id' => 2}]})
      first_question = EpiSurveyor::Question.new
      first_question.id = 1
      second_question = EpiSurveyor::Question.new
      
      second_question.id = 2

      questions = EpiSurveyor::Question.find_all_by_survey(@survey)
      questions.length.should == 2
      first_question.should == questions.first
      second_question.should == questions.last
    end
    
  end
  
  describe '==' do
    it 'should be equal if ids match' do
      a_question = EpiSurveyor::Question.new
      b_question = EpiSurveyor::Question.new
      a_question.should == b_question
    end
  end
end