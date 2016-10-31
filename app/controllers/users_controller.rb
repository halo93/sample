class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index,:edit,:update]
  before_action :load_user, only: [:show, :edit, :update, :destroy]
  before_action :verify_admin, only: [:destroy]
  before_action :verify_correct_user, only: [:edit,:update]

  def index
    per_page = 5
    total_pages = User.count % per_page == 0 ? User.count / per_page
                                             : User.count / per_page + 1
    if total_pages >= params[:page].to_i
      @users = retrieve_activated_users.paginate page: params[:page],
        per_page: per_page
    else
      render file: "public/404.html", layout: false
    end
  end

  def new
    @user = User.new
  end

  def show

  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "pages.users.edit.success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "pages.users.delete.success"
    else
      flash[:danger] = t "pages.users.delete.fail"
    end
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
                                 :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id]
    unless @user.present?
      render file: "public/404.html", layout: false
    end
  end
end
