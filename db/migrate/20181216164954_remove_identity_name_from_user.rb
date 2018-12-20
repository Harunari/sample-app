class RemoveIdentityNameFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :identity_name, :string
  end
end
