# frozen_string_literal: true

require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user),
                    text: full_name(user)
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test 'index not show unavailable users and not transition their own page' do
    log_in_as(@non_admin)
    unavailable_user = users(:ryoutarou)
    get users_path
    assert_select 'a[href=?]', user_path(unavailable_user), text: unavailable_user.name, count: 0
    assert_select 'a[href=?]', user_path(unavailable_user), text: 'delete', count: 0

    get user_path(unavailable_user)
    assert_redirected_to '/'
  end
end
