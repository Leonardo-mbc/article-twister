class CreateRecommendationSources < ActiveRecord::Migration
  def change
    create_table :recommendation_sources do |t|
      t.integer :recommendation_id
      t.integer :news_id

      t.timestamps null: false
    end
  end
end
