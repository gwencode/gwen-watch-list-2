class AddRunTimeAndRevenueToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :run_time, :integer
    add_column :movies, :revenue, :integer, limit: 8
  end
end
