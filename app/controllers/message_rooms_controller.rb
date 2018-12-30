# frozen_string_literal: true

class MessageRoomsController < ApplicationController
  before_action :logged_in_user

  def index
    @message_rooms = current_user.message_rooms
  end

  def show

    addressed_user = User.find(params[:id])
    rooms = current_user.message_rooms
    made_room = rooms.build(receiver: addressed_user)
    made_room.save
    @message = made_room.direct_messages.build
  end
end
