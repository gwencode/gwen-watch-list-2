class MovieGenre < ApplicationRecord
  belongs_to :movie
  belongs_to :genre

  validates :movie, uniqueness: { scope: :genre }
end
