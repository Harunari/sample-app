class AddIdentityName2ToUser < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :identity_name, unique: true
  end
end
