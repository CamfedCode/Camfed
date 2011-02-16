module Admin
  class UsersController < AuthenticatedController

    def index
      @users = User.all
      add_crumb 'Users'
    end
    
    def activate
      @user = User.find(params[:id])
      @user.verified_by_admin = true
      if @user.save
        flash[:notice] = "Successfully activated the user #{@user.email}"
      else
        flash[:error] = "Could not activate the user #{@user.email}. Please see log file."
      end
      redirect_to admin_users_path
    end

    def inactivate
      @user = User.find(params[:id])
      @user.verified_by_admin = false
      if @user.save
        flash[:notice] = "Successfully inactivated the user #{@user.email}"
      else
        flash[:error] = "Could not inactivate the user #{@user.email}. Please see log file."
      end
      redirect_to admin_users_path
    end
    
    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        flash[:notice] = "Successfully deleted the user #{@user.email}"
      else
        flash[:error] = "Could not delete the user #{@user.email}. Please see log file."
      end
      redirect_to admin_users_path
    end


  end
end