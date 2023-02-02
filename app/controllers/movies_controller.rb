# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]

  def index
    if params[:query].present?
      @movies = Movie.where('title ILIKE ?', "%#{params[:query]}%")
    else
      @movies = Movie.all
    end
  end

  def show
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
