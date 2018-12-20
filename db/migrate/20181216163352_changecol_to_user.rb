class ChangecolToUser < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :identity_name, :string, null: false, unique: true
  end

  def down
    change_column :users, :identity_name, :string, null: false
  end
end
