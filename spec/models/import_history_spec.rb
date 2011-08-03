require 'spec_helper'

describe ImportHistory do
  it { should have_many :sync_errors }
  it { should have_many :object_histories }
  it { should belong_to :survey }
  it { should validate_presence_of :survey_id }
  it { should validate_presence_of :survey_response_id }

  describe 'get by status' do
    before(:each) do
      @import_histories = []
      @import_histories << ImportHistory.new(:id =>1,
                                             :sync_errors => [SyncError.new(:id => 21)])
      @import_histories << ImportHistory.new(:id =>2,
                                             :sync_errors => [SyncError.new(:id => 22)])
      @import_histories << ImportHistory.new(:id =>3)
      @survey_id = 123
      ImportHistory.should_receive(:all).with(:include => 'sync_errors',
                                              :conditions => {:survey_id => @survey_id}).and_return(@import_histories)
    end

    it "should return all ImportHistory records for 'All' status parameter" do
      result = ImportHistory.get_by_status(@survey_id, 'All')
      result.count.should be 3
    end

    it "should return only failed ImportHistory records for 'Failure' status parameter" do
      result = ImportHistory.get_by_status(@survey_id, 'Failure')
      result.count.should be 2
    end

    it "should return only successful ImportHistory records for 'Success' status parameter" do
      result = ImportHistory.get_by_status(@survey_id, 'Success')
      result.count.should be 1
    end
  end

end
