require_relative '../services/actor_service'

class ActorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_actor, only: [:show]

  def index
    if params[:query].present? && params[:page].present?
      #TO DO
    elsif params[:query].present? && params[:page].blank?
      actors = Actor.where('name ILIKE ?', "%#{params[:query]}%")
      @actors = actors.reject { |actor| actor.picture_url.empty? }
    elsif params[:page].present? && params[:query].blank?
      # TO DO
      @page_index = params[:page].to_i
      @actors = Actor.all.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20 * @page_index)
      lasts_actors = @actors.last(20)
      render json: lasts_actors
    else
      @actors = Actor.all.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20)
      @page_index = 1
    end
    @actors_count = Actor.all.reject { |actor| actor.picture_url.empty? }.count
  end

  def show
    ActorService.new(@actor).add_biography if @actor.biography.nil?
    popular_movies = @actor.movies.where(popular: true)
    @movies = popular_movies.sort_by { |movie| - movie.rating }

    # other_movies = @actor.movies.where(popular: false)
    # @other_movies = other_movies.sort_by { |movie| - movie.rating }
  end

  private

  def set_actor
    @actor = Actor.find(params[:id])
  end

  def add_biography(actor)
    url_actor = "https://api.themoviedb.org/3/person/#{actor[:api_id]}?api_key=#{API_KEY}&language=en-US"
    actor_details_serialized = URI.open(url_actor).read
    actor_details = JSON.parse(actor_details_serialized)
    actor.update(biography: actor_details['biography'])
  end
end
