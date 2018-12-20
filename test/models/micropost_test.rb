# frozen_string_literal: true

require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @user.id = 1
    @other_user = users(:archer)
    @other_user.id = 2
    @micropost = @user.microposts.build(user_id: 1,
                                        content: 'Lorem ipsum',
                                        in_reply_to: nil)
    @reply_micropost = @user.microposts.build(user_id: 1,
                                              content: "@#{@other_user.identity_name} testPost")
    @reply_micropost.set_reply_id_from_content
    @reply_post_from_other = @other_user.microposts.build(user_id: @other_user.id,
                                                          content: "@#{@user.identity_name} test reply")
    @reply_post_from_other.set_reply_id_from_content
  end

  test 'should be valid' do
    assert @micropost.valid?
  end

  test 'user id should be present' do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content should be present' do
    @micropost.content = '  '
    assert_not @micropost.valid?
  end

  test 'content should be at most 140 characters' do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test 'order should be most recent first' do
    assert_equal microposts(:most_recent), Micropost.first
  end

  test 'in_reply_to item should have nil when id_name is nil or not exist' do
    @reply_nonexist_user = @user.microposts.build(user_id: @user.id,
                                                  content: "@nonExist testPost")
    @reply_nonexist_user.set_reply_id_from_content
    @micropost.set_reply_id_from_content
    assert @reply_nonexist_user.in_reply_to.nil?
    assert @micropost.in_reply_to.nil?
  end

  test 'in_reply_to item should have id when id_name is present' do
    @reply_micropost.set_reply_id_from_content
    assert @reply_micropost.in_reply_to.present?
  end
end
