require 'action_view'
require 'json'
require 'open-uri'

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
        adding_details(new_movie)
        adding_director(new_movie)
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
    api_key = ENV['API_KEY']
    movie_api_id = movie.api_id
    url = "https://api.themoviedb.org/3/movie/#{movie_api_id}/recommendations?api_key=#{api_key}&language=en-US&page=1"
    reco_movies_serialized = URI.open(url).read
    JSON.parse(reco_movies_serialized)['results']
  end

  def adding_details(movie)
    api_key = ENV['API_KEY']
    url_movie = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}?api_key=#{api_key}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    movie.update(run_time: movie_details['runtime'],
                 budget: movie_details['budget'],
                 revenue: movie_details['revenue'],
                 rating: movie_details['vote_average'])
  end

  def adding_director(movie)
    api_key = ENV['API_KEY']
    url_credits = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/credits?api_key=#{api_key}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    crew = JSON.parse(credits_serialized)['crew']
    director = crew.find { |member| member['job'] == 'Director' }
    director_name = director.nil? ? '' : director['name']
    movie.update(director: director_name)
  end
end
