# frozen_string_literal: true

require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(user_id: 1,
                                        content: 'Lorem ipsum',
                                        in_reply_to: nil)
    @reply_micropost = @user.microposts.build(user_id: 1,
                                              content: '@archer1 testPost',
                                              in_reply_to: 2)
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

  test 'should include post which is addressed to indicated user' do
    posts_including_replies = Micropost.including_replies(@user)
    posts_including_replies.each do |post|
      assert_equal @user.id, post.in_reply_to unless post.in_reply_to.blank?
    end
  end

  test 'should extract right identity name' do
    assert_equal 'archer1', @reply_micropost.extract_identity_name
  end

  test 'should in_reply_to item is empty when id_name is nil' do
    @micropost.insert_reply_id_from(@micropost.extract_identity_name)
    assert @micropost.in_reply_to.nil?
  end

  test 'should in_reply_to item is present when id_name is present' do
    @reply_micropost.insert_reply_id_from(@reply_micropost.extract_identity_name)
    assert @reply_micropost.in_reply_to.present?
  end
end
