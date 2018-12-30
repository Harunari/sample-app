# frozen_string_literal: true

require 'test_helper'

class MessageRoomTest < ActiveSupport::TestCase
  def setup
    @room = MessageRoom.new(sender_id: users(:michael).id,
                            receiver_id: users(:malory).id)
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

  test 'order should be most recent updated first' do
    assert_equal message_rooms(:most_recent_michael), MessageRoom.first
  end

  test 'should not valid duplicate same combination of sender and receiver' do
    room_copy = @room.dup
    @room.save
    assert_no_difference 'MessageRoom.count' do
      room_copy.save
    end
  end
end
