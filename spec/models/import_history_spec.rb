require 'spec_helper'

describe ImportHistory do
  it { should have_many :sync_errors }
  it { should have_many :object_histories }
  it { should belong_to :survey }
  it { should validate_presence_of :survey_id }
  it { should validate_presence_of :survey_response_id }

  def mock_import_history(stubs={})
    @mock_import_history ||= mock_model(ImportHistory, stubs).as_null_object
  end

  describe 'get by status' do
    before(:each) do
      @import_histories = []
      @import_histories << ImportHistory.new(:id =>1, :created_at => "2011/07/20",
                                             :sync_errors => [SyncError.new(:id => 21)])
      @import_histories << ImportHistory.new(:id =>2, :created_at => "2011/07/20",
                                             :sync_errors => [SyncError.new(:id => 22)])
      @import_histories << ImportHistory.new(:id =>3, :created_at => "2011/07/20")
      @survey_id = 123
    end

    it "should return all ImportHistory records for 'All' status parameter" do
      mock_scope = mock(anything)
      ImportHistory.should_receive(:scoped).with(any_args).and_return(mock_scope)
      mock_scope.should_receive(:all).with({:include=>"sync_errors"}).and_return(@import_histories)
      result = ImportHistory.get_by_filter(nil, "All", nil, nil)
      result.count.should be 3
    end

    it "should return all ImportHistory records for a particular survey_id and 'All' status parameter" do
      mock_scope = mock(anything)
      ImportHistory.should_receive(:scoped).with(any_args).and_return(mock_scope)
      mock_scope.should_receive(:all).with({:include=>"sync_errors"}).and_return(@import_histories)
      mock_scope.should_receive(:where).with("import_histories.survey_id = ?", @survey_id).and_return(mock_scope)
      result = ImportHistory.get_by_filter(@survey_id, "All", nil, nil)
      result.count.should be 3
    end

    it "should return all ImportHistory records for a particular survey_id and 'All' status and dates" do
      start_date = "2011/07/20"
      end_date = "2011/07/21"
      mock_scope = mock(anything)
      ImportHistory.should_receive(:scoped).with(any_args).and_return(mock_scope)
      mock_scope.should_receive(:all).with({:include=>"sync_errors"}).and_return(@import_histories)
      mock_scope.should_receive(:where).with("import_histories.survey_id = ?", @survey_id).and_return(mock_scope)
      mock_scope.should_receive(:where).with("import_histories.created_at between ? AND ?", start_date, end_date.to_time.advance(:days => 1).to_date).and_return(mock_scope)
      result = ImportHistory.get_by_filter(@survey_id, "All", start_date, end_date)
      result.count.should be 3
    end

    it "should return only failed ImportHistory records for 'Failure' status parameter" do
      mock_scope = mock(anything)
      ImportHistory.should_receive(:scoped).with(any_args).and_return(mock_scope)
      mock_scope.should_receive(:all).with({:include=>"sync_errors"}).and_return(@import_histories)
      result = ImportHistory.get_by_filter(nil, "Failed", nil, nil)
      result.count.should be 2
    end

    it "should return only successful ImportHistory records for 'Success' status parameter" do
      mock_scope = mock(anything)
      ImportHistory.should_receive(:scoped).with(any_args).and_return(mock_scope)
      mock_scope.should_receive(:all).with({:include=>"sync_errors"}).and_return(@import_histories)
      result = ImportHistory.get_by_filter(nil, "Success", nil, nil)
      result.count.should be 1
    end
  end

end
