# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]

  def index
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
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
