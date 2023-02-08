class AddGenreReferenceToMovies < ActiveRecord::Migration[7.0]
  def change
    add_reference :movies, :genre, foreign_key: true
  end
end
