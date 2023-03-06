require_relative '../services/actor_service'
require_relative '../services/movie_service'

class ActorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_actor, only: [:show]

  def index
    # Initialize casts at first use in production
    # ActorService.new.reset_actors
    # ActorService.new.init_prod if Cast.count <= 30000

    if params[:query].present? && params[:page].present?
      @page_index = params[:page].to_i
      actors = Actor.where('name ILIKE ?', "%#{params[:query]}%")
      @actors = actors.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20 * @page_index)
      actors_count = actors.reject { |actor| actor.picture_url.empty? }.count
      lasts_actors = actors_count > 20 * @page_index ? @actors.last(20) : @actors.last(actors_count - 20 * (@page_index - 1))
      render json: lasts_actors
    elsif params[:query].present? && params[:page].blank?
      actors = Actor.where('name ILIKE ?', "%#{params[:query]}%")
      @actors = actors.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20)
      actors_count = actors.reject { |actor| actor.picture_url.empty? }.count
      @page_index = 1
    elsif params[:page].present? && params[:query].blank?
      @page_index = params[:page].to_i
      @actors = Actor.all.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20 * @page_index)
      lasts_actors = @actors.last(20)
      render json: lasts_actors
    else
      @actors = Actor.all.reject { |actor| actor.picture_url.empty? }.sort_by(&:name).first(20)
      @page_index = 1

      # Find a random movie without casts and add casts
      # random_movie = Movie.where("popular = ? AND NOT EXISTS (SELECT 1 FROM casts WHERE movie_id = movies.id)", true).order("RANDOM()").first
      # MovieService.new.parse_actors_casts(random_movie)
    end
    @actors_count = actors_count || Actor.all.reject { |actor| actor.picture_url.empty? }.count

    # respond_to do |format|
    #   format.html # Follow regular flow of Rails
    #   format.json # Render the index.json.jbuilder template
    # end
  end

  def show
    ActorService.new.add_biography(@actor) if @actor.biography.nil?
    popular_movies = @actor.movies.where(popular: true)
    @movies = popular_movies.sort_by(&:title)
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
