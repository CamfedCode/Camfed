class CamfedSigninPage
  include PageObject

  direct_url "#{EnvConfig.get :camfed, :url}/users/sign_in"

  text_field :email, :id => 'user_email'
  text_field :password, :id => 'user_password'
  button :signin, :id => 'user_submit'

  def signin_to_camfed
    if self.email_text_field.exists?
      self.email = EnvConfig.get :camfed, :username
      self.password = EnvConfig.get :camfed, :password
      signin
    end
  end
end