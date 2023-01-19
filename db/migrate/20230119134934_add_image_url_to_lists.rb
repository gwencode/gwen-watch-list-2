# frozen_string_literal: true

# Add image_url to lists
class AddImageUrlToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :image_url, :string
  end
end
