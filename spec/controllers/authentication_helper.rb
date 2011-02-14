include Devise::TestHelpers
def sign_on
  user = create_user 'test@test.com'
  user.verified_by_admin = true
  user.save!
  sign_in :user, user
end

def create_user email
  User.create(:email => email, 
  :password => 'thepass', 
  :password_confirmation => 'thepass')
end