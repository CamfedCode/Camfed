class AuthenticatedController < ApplicationController
  before_filter :authenticate_verified_user!

  add_crumb 'Home', '/'

  protected
  def authenticate_verified_user!
    logger.debug "CURRENT user = #{current_user.inspect}"
    unless current_user.verified_by_admin?
      flash[:error] = 'Only activated users are allowed to visit this page.'
      redirect_to home_path
    end
  end
end