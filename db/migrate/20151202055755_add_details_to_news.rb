class AddDetailsToNews < ActiveRecord::Migration
  def change
    add_column :news, :topic_id, :string
    add_column :news, :source, :string
    add_column :news, :url, :string
    add_column :news, :host, :string
  end
end
