require 'spec_helper'
require 'controllers/authentication_helper'

describe Admin::UsersController do
  before(:each) do
    sign_on
  end
  
  describe "PUT 'activate'" do
    it "should update the users activated status to true" do
      user = create_user 'some@email.com'
      put 'activate', :id => user.id
      user.reload
      user.verified_by_admin?.should be true
      response.should redirect_to admin_users_path
    end
  end
  
  describe "PUT 'inactivate'" do

    it "should update the users activated status to false" do
      user = create_user 'some@email.com'
      put 'inactivate', :id => user.id
      user.reload
      user.verified_by_admin?.should be false
      response.should redirect_to admin_users_path
    end
  end
  
  describe 'index' do
    it 'shoould populate the users list' do
      get :index
      assigns[:users].should have(1).things
    end
  end
  
  describe 'destroy' do
    it 'should delete a user' do
      user = create_user 'email@example.com'
      delete :destroy, :id => user.id
      assigns[:user].frozen?.should be true
      response.should redirect_to admin_users_path
    end
  end
  
end