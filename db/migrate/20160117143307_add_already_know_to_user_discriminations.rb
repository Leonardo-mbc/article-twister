class AddAlreadyKnowToUserDiscriminations < ActiveRecord::Migration
  def change
    add_column :user_discriminations, :already_know, :boolean
  end
end
