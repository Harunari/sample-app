class ChangeToMicroposts < ActiveRecord::Migration[5.2]
  def change
    remove_column :microposts, :in_reply_to, :string
    add_column :microposts, :in_reply_to, :integer
  end
end
