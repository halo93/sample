class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :load_a_micropost, only: [:destroy]
  
  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "micropost.success"
      redirect_to root_url
    else
      @feed_items = feed_list
      flash[:warning] = t "micropost.fail"
      render "static_pages/home"
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "micropost.delete.success"
    redirect_to request.referrer || root_url
  end

  private
  def micropost_params
    params.require(:micropost).permit :content, :picture
  end

  def load_a_micropost
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_url if @micropost.nil?
  end
end
