class EpiSurveyorHomePage
  include PageObject

  direct_url EnvConfig.get :epi, :url
  expected_title 'EpiSurveyor: Mobile Data Collection Made Simple'

  text_field :email, :id => 'email'
  text_field :password, :id => 'password'
  button :login, :id => 'login'

  def login_to_epi
    self.email = EnvConfig.get :epi, :username
    self.password = EnvConfig.get :epi, :password
    login
  end
end