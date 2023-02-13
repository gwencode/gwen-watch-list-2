require 'action_view'
require 'json'
require 'open-uri'

API_KEY = ENV['API_KEY']

class Movie < ApplicationRecord
  has_many :bookmarks
  has_many :lists, through: :bookmarks
  has_many :casts
  has_many :actors, through: :casts
  has_many :movie_genres
  has_many :genres, through: :movie_genres

  validates :title, presence: true, uniqueness: true

  include PgSearch::Model
  pg_search_scope :search_by_title,
                  against: :title,
                  using: { tsearch: { prefix: true }, trigram: { word_similarity: true } }

  include ActionView::Helpers::NumberHelper
  def formatted_budget
    number_with_delimiter(budget, delimiter: ',')
  end

  def formatted_revenue
    number_with_delimiter(revenue, delimiter: ',')
  end

  def reco_movies
    reco_movies = parsing_reco_movies(self)
    five_reco_movies = []
    reco_movies.each do |movie|
      next if five_reco_movies.count == 5

      if Movie.find_by(api_id: movie['id']).nil?
        new_movie = Movie.create(
          title: movie['title'],
          overview: movie['overview'],
          poster_url: movie['poster_path'].nil? ? '' : "https://image.tmdb.org/t/p/w400#{movie['poster_path']}",
          backdrop_url: movie['backdrop_path'].nil? ? '' : "https://image.tmdb.org/t/p/w1280#{movie['backdrop_path']}",
          release_date: movie['release_date'],
          api_id: movie['id'],
          popular: false
        )
        five_reco_movies << new_movie if new_movie.valid?
      else
        movie = Movie.find_by(api_id: movie['id'])
        five_reco_movies << movie if movie.valid?
      end
    end
    five_reco_movies
  end

  private

  def parsing_reco_movies(movie)
    movie_api_id = movie.api_id
    url = "https://api.themoviedb.org/3/movie/#{movie_api_id}/recommendations?api_key=#{API_KEY}&language=en-US&page=1"
    reco_movies_serialized = URI.open(url).read
    JSON.parse(reco_movies_serialized)['results']
  end
end
