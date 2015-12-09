class CreateUserDiscriminations < ActiveRecord::Migration
  def change
    create_table :user_discriminations do |t|
      t.integer :user_id
      t.integer :news_id
      t.integer :sign

      t.timestamps null: false
    end
  end
end
