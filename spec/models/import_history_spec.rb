require 'spec_helper'

describe ImportHistory do
  it {should have_many :sync_errors }
  it {should have_many :object_histories }
  it {should belong_to :survey}
  it {should validate_presence_of :survey_id}
  it {should validate_presence_of :survey_response_id}
end
