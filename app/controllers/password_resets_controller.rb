class PasswordResetsController < ApplicationController
  before_action :retrieve_user_by_email,
    :verify_user, :check_expiration, only: [:edit, :update]
  
  def new
  end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_resets.new.info"
      redirect_to root_url
    else
      flash.now[:danger] = t "password_resets.new.danger"
      render :new
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("password_resets.errors")
      render :edit
    elsif @user.update_attributes user_params
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t "password_resets.success"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def retrieve_user_by_email
    @user = User.find_by email: params[:email]
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "password_resets.check_expiration"
      redirect_to new_password_reset_url
    end
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end
end
