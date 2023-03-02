require_relative '../services/movie_service'

class MyMoviesController < ApplicationController
  def index
    @user = current_user
    @movies = @user.movies.uniq

    # Update a random page of movies each time a user goes to this page
    movies = MovieService.new.parse_movies(rand(1..500))
    puts "_______________________________________________________"
    puts "Movies updated: #{movies.count}"
    puts "Movies page: #{movies.first.page_index}"
  end
end
