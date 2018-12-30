class DirectMessagesController < ApplicationController
  before_action :logged_in_user, only: %i[create]

  def create
    # this is wrong code
    # TODO: create current_room helper method
    room_id = session[:current_room_id]
    @message = MessageRoom.find_by(id: 2).direct_messages.build(direct_message_params)
    if @message.save
      redirect_to message_room_path(id: 2)
    else
      render 'static_pages/home'
    end
  end

  private

  def direct_message_params
    params.require(:direct_message).permit(:content)
  end
end
