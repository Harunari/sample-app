# frozen_string_literal: true

class AddUserIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user_id, :string, unique: true
  end
end
