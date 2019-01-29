# frozen_string_literal: true

require 'test_helper'

class SubscribeFavoriteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = microposts(:ants)
    log_in_as(@user)
  end

  test 'should subscribe favorite a micropost the standard way' do
    assert_difference '@user.favorite_microposts.count', 1 do
      post favorite_microposts_path, params: { micropost_id: @micropost.id }
    end
  end

  test 'should subscribe favorite a micropost with Ajax' do
    assert_difference '@user.favorite_microposts.count', 1 do
      post favorite_microposts_path, xhr: true, params: { micropost_id: @micropost.id }
    end
  end

  test 'should subscribe unfavorite a micropost the standard way' do
    @user.favorite(@micropost)
    fav_info = @user.favorites.find_by(micropost_id: @micropost.id)
    assert_difference '@user.favorite_microposts.count', -1 do
      delete favorite_micropost_path(fav_info)
    end
  end

  test 'should subscribe unfavorite a micropost with Ajax' do
    @user.favorite(@micropost)
    fav_info = @user.favorites.find_by(micropost_id: @micropost.id)
    assert_difference '@user.favorite_microposts.count', -1 do
      delete favorite_micropost_path(fav_info), xhr: true
    end
  end
end
