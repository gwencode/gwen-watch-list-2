class MyMoviesController < ApplicationController
  def index
    @user = current_user
    @movies = @user.movies.uniq
  end
end
