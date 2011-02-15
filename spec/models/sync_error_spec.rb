require 'spec_helper'

describe SyncError do
  it {should validate_presence_of :salesforce_object}
end
