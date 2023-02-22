require "json"
require "open-uri"
API_KEY = ENV['API_KEY']

class GenreService
  def set_genres
    url_genres = "https://api.themoviedb.org/3/genre/movie/list?api_key=b72ba5cb73d0620eee541d35e3adab4c&language=en-US"
    genres_serialized = URI.open(url_genres).read
    genres = JSON.parse(genres_serialized)['genres']
    genres.each do |genre|
      Genre.create(name: genre['name'], api_id: genre['id'])
    end
  end
end
