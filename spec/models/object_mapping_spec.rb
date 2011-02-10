require 'spec_helper'

describe ObjectMapping do
  it {should have_many :field_mappings }
  it {should belong_to :survey }
end