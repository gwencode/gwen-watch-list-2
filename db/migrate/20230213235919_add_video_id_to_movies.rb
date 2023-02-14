class AddVideoIdToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :video_id, :string
  end
end
