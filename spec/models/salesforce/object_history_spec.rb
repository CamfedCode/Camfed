require 'spec_helper'

describe Salesforce::ObjectHistory do
  it {should validate_presence_of :salesforce_object}
  it {should validate_presence_of :salesforce_id}
end
