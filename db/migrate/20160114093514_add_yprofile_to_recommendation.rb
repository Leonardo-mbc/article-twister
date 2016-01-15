class AddYprofileToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :y_profile, :integer
  end
end
