require "json"
require "open-uri"
require_relative "movie_service"

class ActorService
  def add_biography(actor)
    url_actor = "https://api.themoviedb.org/3/person/#{actor[:api_id]}?api_key=#{API_KEY}&language=en-US"
    actor_details_serialized = URI.open(url_actor).read
    actor_details = JSON.parse(actor_details_serialized)
    actor.update(biography: actor_details['biography'])
  end

  def init_prod
    Cast.destroy_all
    Actor.destroy_all
    movie_service = MovieService.new
    Movie.where(popular: true).each {|movie| movie_service.parse_actors_casts(movie) if movie.casts.empty? }
  end
end
