class AddDetailsToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :release_date, :string
    add_column :movies, :api_id, :integer
    add_column :movies, :budget, :integer, limit: 8
    add_column :movies, :director, :string
  end
end
