class ActorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_actor, only: [:show]

  def index
    @actors = Actor.all.reject { |actor| actor.picture_url.empty? || actor.biography.empty? }
  end

  def show
    popular_movies = @actor.movies.where(popular: true)
    @movies = popular_movies.sort_by { |movie| - movie.rating }

    # other_movies = @actor.movies.where(popular: false)
    # @other_movies = other_movies.sort_by { |movie| - movie.rating }
  end

  private

  def set_actor
    @actor = Actor.find(params[:id])
  end
end
