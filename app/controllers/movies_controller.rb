# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]

  def index
    popular_movies = Movie.where(popular: true).sort_by { |movie| - movie.rating }
    if params[:query].present?
      @movies = popular_movies.where('title ILIKE ?', "%#{params[:query]}%")
    else
      @movies = popular_movies
    end
  end

  def show
    @reco_movies = @movie.reco_movies
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
