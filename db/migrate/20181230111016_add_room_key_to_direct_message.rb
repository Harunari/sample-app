class AddRoomKeyToDirectMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :direct_messages, :message_room_id, :integer
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
