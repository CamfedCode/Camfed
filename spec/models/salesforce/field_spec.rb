require "spec_helper"

describe Salesforce::Field do
  
  describe '==' do
    before(:each) do
      @field = Salesforce::Field.new("the_name", "The Name", "string")
    end
    
    it 'should be false if other is nil' do
      (@field == nil).should be false
    end
    
    it "should be true if other is equal" do
      other_field = Salesforce::Field.new("the_name")
      (@field == other_field).should be true
    end
    
    it "should be false if other has a different name" do
      other_field = Salesforce::Field.new("other_name")
      (@field == other_field).should be false
    end
  end
end