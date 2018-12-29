# frozen_string_literal: true

require 'test_helper'

class MessageRoomTest < ActiveSupport::TestCase
  def setup
    @room = MessageRoom.new(sender_id: users(:michael).id,
                          receiver_id: users(:archer).id)
  end

  test 'should be valid' do
    assert @room.valid?
  end

  test 'should require a sender_id' do
    @room.sender_id = nil
    assert_not @room.valid?
  end

  test 'should require a receiver_id' do
    @room.receiver_id = nil
    assert_not @room.valid?
  end
end
