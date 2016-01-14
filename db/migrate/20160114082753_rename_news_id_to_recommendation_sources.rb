class RenameNewsIdToRecommendationSources < ActiveRecord::Migration
  def change
    rename_column :recommendation_sources, :news_id, :source
  end
end
