class FavoriteMicropostsController < ApplicationController
  before_action :logged_in_user
  def create
    @micropost = Micropost.find(params[:micropost_id])
    current_user.favorite(@micropost)
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js
    end
  end

  def destroy
    favorite_info = FavoriteMicropost.find(params[:id])
    @micropost = favorite_info.subscribed_post;
    current_user.unfavorite(@micropost)
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js
    end
  end
end
