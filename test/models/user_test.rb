# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', identity_name: 'exapmle_user_1',
                     email: 'user@example.com', password: 'foobar',
                     password_confirmation: 'foobar')
    @me = users(:michael)
    @not_followed_user = users(:archer)
    @followed_user = users(:lana)
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '  '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '  '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a use with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'feed should have the right posts' do
    michael = users(:michael)
    archer = users(:archer)

    # confirm own microposts
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # confirm microposts of not following user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end

  test 'feed should not have non-reply micropost of not followed user' do
    @not_followed_user.microposts.build(content: 'this isnt reply',
                                        in_reply_to: nil)
    assert_not @me.feed.map(&:content).include?('this isnt reply')
  end

  test 'feed should have a reply post even if it is tweeted by unfollowed user' do
    reply_content = "@#{@me.identity_name} feafaefaadafdak"
    @not_followed_user.microposts.build(content: reply_content,
                                        in_reply_to: @me.id).save
    assert @me.feed.map(&:content).include?(reply_content)
  end

  test 'feed should not have a reply post not to me even if user is following the sender' do
    reply_content = "@#{@not_followed_user.identity_name} test micropost"
    @followed_user.microposts.build(content: reply_content,
                                    in_reply_to: @not_followed_user.id).save
    assert_not @me.feed.map(&:content).include?(reply_content)
  end

  test 'feed should have post which is myself to another' do
    reply_content = "@#{@followed_user.identity_name} test micropost"
    @me.microposts.build(content: reply_content,
                         in_reply_to: @followed_user.id).save
    assert @me.feed.map(&:content).include?(reply_content)
  end
end
