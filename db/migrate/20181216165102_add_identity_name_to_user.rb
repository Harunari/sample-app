class AddIdentityNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :identity_name, :string
    change_column :users, :identity_name, :string, :unique => true, :null => false
  end
end
