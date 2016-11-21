class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items = feed_list
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
