class CreateFavoriteMicroposts < ActiveRecord::Migration[5.2]
  def change
    create_table :favorite_microposts do |t|
      t.integer :subscriber_id
      t.integer :micropost_id

      t.timestamps
    end
    add_index :favorite_microposts, :subscriber_id
    add_index :favorite_microposts, :micropost_id
    add_index :favorite_microposts, [:subscriber_id, :micropost_id], unique: true
  end
end
