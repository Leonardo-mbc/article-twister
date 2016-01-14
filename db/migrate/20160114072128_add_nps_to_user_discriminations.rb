class AddNpsToUserDiscriminations < ActiveRecord::Migration
  def change
    add_column :user_discriminations, :nps, :integer
  end
end
