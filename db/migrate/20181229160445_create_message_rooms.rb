class CreateMessageRooms < ActiveRecord::Migration[5.2]
  def change


    create_table :message_rooms do |t|
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
    add_index :message_rooms, :sender_id
    add_index :message_rooms, :receiver_id
    add_index :message_rooms, [:sender_id, :receiver_id], unique: true
  end
end
