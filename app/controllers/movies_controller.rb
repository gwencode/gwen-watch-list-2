# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]
  before_action :set_user, only: %i[show]

  def index
    popular_movies = Movie.where(popular: true)
    if params[:query].present?
      popular_movies = popular_movies.where('title ILIKE ?', "%#{params[:query]}%")
    end

    if params[:genre].present?
      popular_movies = popular_movies.joins(:genres).where(genres: { id: params[:genre].to_i })
    end

    @movies = popular_movies.sort_by { |movie| movie.id }
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

end
