class SmsResponse < ActiveRecord::Base
  serialize :properties, Hash   #currently possible keys for this hash are :error, :mobile_number, :stat, :credit
  attr_accessible :sms_id, :properties
end
