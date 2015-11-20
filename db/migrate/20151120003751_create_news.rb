class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.integer :news_id

      t.timestamps null: false
    end
  end
end
