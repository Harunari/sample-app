# frozen_string_literal: true

require 'test_helper'

class FavoriteMicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = microposts(:cat_video)
  end

  test 'create should require logged-in user' do
    assert_no_difference 'FavoriteMicropost.count' do
      post favorite_microposts_path,
           params: { micropost_id: @micropost.id }
    end
    assert_redirected_to login_url
  end

  test 'destroy should require logged-in user' do
    assert_no_difference 'FavoriteMicropost.count' do
      delete favorite_micropost_path(favorite_microposts(:two))
    end
    assert_redirected_to login_url
  end

  test 'should increase favorites when subscribe' do
    log_in_as(@user)
    assert_difference 'FavoriteMicropost.count', 1 do
      post favorite_microposts_path,
           params: { micropost_id: @micropost.id }
    end
  end

  test 'should decrease favorites when cancel subscribe' do
    log_in_as(@user)
    assert_difference 'FavoriteMicropost.count', -1 do
      delete favorite_micropost_path(favorite_microposts(:two))
    end
  end
end
