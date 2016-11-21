class CommentsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = Micropost.find_by id: params[:micropost_id]
    @comment = @micropost.comments.create comment_params
    @comment.user = current_user
    respond_to do |format|
      if @comment.save!
          format.html{redirect_to @micropost}
          format.js
      end
    end
  end

  def destroy
    @micropost = Micropost.find_by id: params[:micropost_id]
    @comment = @micropost.comments.find params[:id]
    @comment.destroy
    flash.now[:success] = t "comments.deleted"
    respond_to do |format|
      format.html{redirect_to @micropost}
      format.js
    end
  end

  private
  def comment_params
    params.require(:comment).permit :content, :user_id, :micropost_id
  end
end
