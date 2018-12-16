# frozen_string_literal: true

require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                         identity_name: '',
                                         email: 'user@invalid',
                                         password: 'foo',
                                         password_confirmation: 'bar' } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div.alert-danger'
    assert_select 'form[action= "/signup"]'
  end

  test 'valid signup information with account activation' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         identity_name: 'example_user_1',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # login while not activated.
    log_in_as(user)
    assert_not is_logged_in?
    # token for activate account is invalid
    get edit_account_activation_path('invalid token', email: user.email)
    assert_not is_logged_in?
    # In case token is right, but mail address is invalid
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # token for activation is right
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test 'signup forms' do
    get signup_path
    assert_select 'input[id=?]', 'user_name', count: 1
    assert_select 'input[id=?]', 'user_email', count: 1
    assert_select 'input[id=?]', 'user_password', count: 1
    assert_select 'input[id=?]', 'user_password_confirmation', count: 1
    assert_select 'input[id=?]', 'user_identity_name', count: 1
  end
end
