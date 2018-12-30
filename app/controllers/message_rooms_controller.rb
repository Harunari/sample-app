# frozen_string_literal: true

class MessageRoomsController < ApplicationController
  before_action :logged_in_user

  def index
    @message_rooms = current_user.message_rooms.paginate(page: params[:page])
  end

  def show
    addressed_user = User.find(params[:id])
    current_user.message_rooms.create(receiver: addressed_user)
  end
end
