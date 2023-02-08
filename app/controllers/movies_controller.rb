# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]
  before_action :set_user, only: %i[show]

  def index
    # get_movies
    if params[:query].present?
      popular_movies = Movie.where(popular: true).where('title ILIKE ?', "%#{params[:query]}%")
    else
      popular_movies = Movie.where(popular: true)
    end
    @movies = popular_movies.sort_by { |movie| - movie.rating }
  end

  def show
    @reco_movies = @movie.reco_movies
    @bookmark = Bookmark.new
    @list = List.new(user_id: @user)
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  # def get_movies
  #   url = ENV['API_URL']
  #   api_key = ENV['API_KEY']

  #   (1..5).to_a.each do |page_index|
  #     # change 5 in 36885 to have all pages of the API
  #     url_page = "#{url}&page=#{page_index}"
  #     movies_serialized = URI.open(url_page).read
  #     movies = JSON.parse(movies_serialized)['results']
  #     movies.each do |movie|
  #       new_movie = Movie.find_or_create_by(
  #         title: movie['title'],
  #         api_id: movie['id']
  #       )
  #       next if new_movie.id.nil?

  #       new_movie.update(
  #         overview: movie['overview'],
  #         poster_url: movie['poster_path'].nil? ? '' : "https://image.tmdb.org/t/p/w500#{movie['poster_path']}",
  #         backdrop_url: movie['backdrop_path'].nil? ? '' : "https://image.tmdb.org/t/p/w1280#{movie['backdrop_path']}",
  #         rating: movie['vote_average'],
  #         release_date: movie['release_date'],
  #         popular: true)

  #       url_movie = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}?api_key=#{api_key}&language=en-US"
  #       movie_details_serialized = URI.open(url_movie).read
  #       movie_details = JSON.parse(movie_details_serialized)
  #       new_movie.update(run_time: movie_details['runtime'], budget: movie_details['budget'], revenue: movie_details['revenue'])

  #       url_credits = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}/credits?api_key=#{api_key}&language=en-US"
  #       credits_serialized = URI.open(url_credits).read
  #       crew = JSON.parse(credits_serialized)['crew']
  #       director = crew.find { |member| member['job'] == 'Director' }
  #       director_name = director.nil? ? '' : director['name']
  #       new_movie.update(director: director_name)
  #     end
  #   end
  # end
end
# end of class
