class User < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :user_id
    add_column :users, :identity_name, :string, :unique => true
  end
end
