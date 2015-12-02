class AddSourceToProfileSources < ActiveRecord::Migration
  def change
    add_column :profile_sources, :source, :integer
  end
end
