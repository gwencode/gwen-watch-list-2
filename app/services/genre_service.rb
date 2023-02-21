require "json"
require "open-uri"
API_KEY = ENV['API_KEY']

class GenreService
  def set_genres
    url_genres = "https://api.themoviedb.org/3/genre/movie/list?api_key=#{API_KEY}&language=en-US"
    genres_serialized = URI.open(url_genres).read
    genres = JSON.parse(genres_serialized)['genres']
    genres.each do |genre|
      Genre.create(name: genre['name'], api_id: genre['id'])
    end
  end
end
