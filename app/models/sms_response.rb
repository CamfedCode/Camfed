class SmsResponse < ActiveRecord::Base
  attr_accessible :sms_id, :date_sent, :message_body, :sent_to, :price
end
