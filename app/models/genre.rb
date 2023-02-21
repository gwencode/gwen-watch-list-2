class Genre < ApplicationRecord
  has_many :movie_genres
  has_many :movies, through: :movie_genres

  validates :name, :api_id, presence: true
  validates :name, uniqueness: { scope: :api_id}
end
