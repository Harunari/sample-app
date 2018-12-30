# frozen_string_literal: true

require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'user profile display' do
    log_in_as(@user)
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: full_name(@user)
    assert_select 'h1>img.gravatar'
    assert_select 'a[href=?]', message_room_path(@user), count: 0
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
    assert_select 'div[class=?]', 'pagination', count: 1
  end

  test 'other user profie display' do
    # When not logged in
    get user_path(@other_user)
    assert_select 'a[href=?]', message_room_path(@user), count: 0
    log_in_as(@user)
    get user_path(@other_user)
    assert_select 'a[href=?]', message_room_path(@other_user)
  end
end
