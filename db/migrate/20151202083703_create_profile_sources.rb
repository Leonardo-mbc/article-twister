class CreateProfileSources < ActiveRecord::Migration
  def change
    create_table :profile_sources do |t|
      t.integer :profile_id

      t.timestamps null: false
    end
  end
end
