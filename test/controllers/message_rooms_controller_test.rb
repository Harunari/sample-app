# frozen_string_literal: true

require 'test_helper'

class MessageRoomsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should redirect index when not logged in' do
    get message_rooms_path
    assert_redirected_to login_url
  end

  test 'should redirect show when not logged in' do
    assert_no_difference 'MessageRoom.count' do
      get message_room_path(@other_user)
    end
    assert_redirected_to login_url
  end

  test 'should insert message room info when enter dm room' do
    log_in_as(@user)
    assert_difference 'MessageRoom.count', 1 do
      get message_room_path(@other_user)
    end
  end

  test 'should insert message room which is opposite when send dm' do
    log_in_as(@user)
    assert_difference "MessageRoom.count", 1 do
      # TODO post direct_message_path(@other_user)
    end
  end
end
