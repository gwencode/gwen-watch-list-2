require_relative '../services/actor_service'
require_relative '../services/movie_service'

class ActorsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_actor, only: [:show]

  def index
    movie_service = MovieService.new

    # Initialize casts at first use in production
    if Cast.count < 6000
      Movie.where(popular: true).select {|movie| movie.page_index <= 100 }.each { |movie| movie_service.parse_actors_casts(movie) }
    elsif Cast.count < 12000
      Movie.where(popular: true).select {|movie| (101..200).include?(movie.page_index) }.each { |movie| movie_service.parse_actors_casts(movie) }
    elsif Cast.count < 18000
      Movie.where(popular: true).select {|movie| (201..300).include?(movie.page_index) }.each { |movie| movie_service.parse_actors_casts(movie) }
    elsif Cast.count < 24000
      Movie.where(popular: true).select {|movie| (301..400).include?(movie.page_index) }.each { |movie| movie_service.parse_actors_casts(movie) }
    elsif Cast.count < 30000
     Movie.where(popular: true).select {|movie| (401..500).include?(movie.page_index) }.each { |movie| movie_service.parse_actors_casts(movie) }
    end

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
    end
    @actors_count = actors_count || Actor.all.reject { |actor| actor.picture_url.empty? }.count

    # Add casts to a movie at each page load
    movie = Movie.where(overview: nil).first
    MovieService.new.add_biography(movie)
    MovieService.new.parse_actors_casts(movie)
  end

  def show
    ActorService.new(@actor).add_biography if @actor.biography.nil?
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
