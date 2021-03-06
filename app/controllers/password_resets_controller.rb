class PasswordResetsController < ApplicationController
  before_action :get_valid_user, only:[:edit, :update]
  before_action :check_experation, only:[:edit, :update]
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user  
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
     
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = 'Password has been reset'
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def edit
  end
  
  private
    def get_valid_user
      @user = User.find_by(email: params[:email])
      unless @user
        redirect_to root_url
      end
    end
    
    def check_experation
      if @user.password_resert_expired?
        flash[:danger] = "Password reset has expired"
        redirect_to new_password_reset_url
      end
    end
    
    def user_params
      params.require(:user).permit(:password,:password_confirmation)
    end
end
