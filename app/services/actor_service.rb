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

  def reset_actors
    Cast.destroy_all
    Actor.destroy_all
  end

  def init_prod
    movie_service = MovieService.new
    until Cast.count <= 30000
      Movie.where(popular: true).each {|movie| movie_service.parse_actors_casts(movie) if movie.casts.empty? && Cast.count <= 30000}
    end
  end
end
