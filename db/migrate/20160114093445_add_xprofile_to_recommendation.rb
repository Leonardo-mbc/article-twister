class AddXprofileToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :x_profile, :integer
  end
end
