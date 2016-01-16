class AddTunedToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :tuned, :boolean
  end
end
