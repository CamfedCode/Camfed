require 'spec_helper'

describe SmsResponse do
  it "should serialize the hash" do
    sms_response = SmsResponse.new(:sms_id=>"e3debdc7f4719ec0", :properties => {:stat=>"ok",  :credit => 500})
    sms_response.save
    sms_response = SmsResponse.where(:sms_id => "e3debdc7f4719ec0").first
    sms_response.properties[:stat].should == "ok"
  end
end
