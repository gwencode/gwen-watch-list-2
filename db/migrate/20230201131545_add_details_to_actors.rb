class AddDetailsToActors < ActiveRecord::Migration[7.0]
  def change
    add_column :actors, :actor_api_id, :integer
    add_column :actors, :order, :integer
  end
end
