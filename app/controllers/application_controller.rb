class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  PER_PAGE = 5

  def verify_correct_user
    redirect_to root_url unless current_user? @user
  end

  def verify_admin
    redirect_to root_url unless current_user.admin?
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "authorize_fail"
      redirect_to login_url
    end
  end

  protected
  def verify_user
    unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def total_pages model
    model.count % PER_PAGE == 0 ? model.count / PER_PAGE : model.count / PER_PAGE + 1
  end

  def feed_list
    current_user.feed.paginate page: params[:page],
      per_page: PER_PAGE
  end
end
