class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :load_a_micropost, only: [:show, :destroy]

  def show
    @comments = @micropost.comments.paginate page: params[:page],
      per_page: PER_PAGE
  end

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "micropost.success"
    else
      @feed_items = feed_list
      flash[:warning] = t "micropost.fail"
    end
    respond_to do |format|
      format.html {redirect_to request.referrer || root_url}
      format.js
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "micropost.delete.success"
    respond_to do |format|
      format.html {redirect_to request.referrer || root_url}
      format.js
    end
  end

  private
  def micropost_params
    params.require(:micropost).permit :content, :picture
  end

  def load_a_micropost
    @micropost = Micropost.find_by id: params[:id]
    redirect_to root_url if @micropost.nil?
  end
end
