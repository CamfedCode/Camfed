class User < ActiveRecord::Base
  validates :name,
    :length => { :minimum => 2, :maximum => 24, :message => "has invalid length"},
    :presence => {:message => "can't be blank"}
  validates :last_name,
    :length => { :minimum => 2, :maximum => 24, :message => "has invalid length"},
    :presence => {:message => "can't be blank"}
  validates :address,
    :length => { :minimum => 5, :message => "too short length"},
    :presence => {:message => "can't be blank"}
  validates :email,
    :presence => {:message => "can't be blank"},
    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "has wrong email format"}
  validates :zip, :numericality => true, :length => { :minimum => 5 }
end