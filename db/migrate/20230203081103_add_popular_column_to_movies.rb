class AddPopularColumnToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :popular, :boolean, default: false
  end
end
