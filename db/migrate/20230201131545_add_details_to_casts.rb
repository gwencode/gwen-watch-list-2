class AddDetailsToCasts < ActiveRecord::Migration[7.0]
  def change
    add_column :casts, :actor_api_id, :integer
    add_column :casts, :order, :integer
    add_column :casts, :character, :string
  end
end
