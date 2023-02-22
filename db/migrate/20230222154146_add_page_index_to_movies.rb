class AddPageIndexToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :page_index, :integer
  end
end
