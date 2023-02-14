require "json"
require "open-uri"
API_KEY = ENV['API_KEY']

class ActorService
  def initialize(actor)
    @actor = actor
  end

  def add_biography
    url_actor = "https://api.themoviedb.org/3/person/#{@actor[:api_id]}?api_key=#{API_KEY}&language=en-US"
    actor_details_serialized = URI.open(url_actor).read
    actor_details = JSON.parse(actor_details_serialized)
    @actor.update(biography: actor_details['biography'])
  end
end
