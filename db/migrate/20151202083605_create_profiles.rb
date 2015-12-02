class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :profile

      t.timestamps null: false
    end
  end
end
