# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'json'
require 'open-uri'

puts 'Cleaning database...'
Bookmark.destroy_all
MovieGenre.destroy_all
List.destroy_all
User.destroy_all
Cast.destroy_all
Actor.destroy_all
Movie.destroy_all
Genre.destroy_all

url = ENV['API_URL']
api_key = ENV['API_KEY']

puts 'Creating genres...'

url_genres = "https://api.themoviedb.org/3/genre/movie/list?api_key=#{api_key}&language=en-US"
genres_serialized = URI.open(url_genres).read
genres = JSON.parse(genres_serialized)['genres']
genres.each do |genre|
  Genre.create(name: genre['name'], api_id: genre['id'])
end

puts "#{Genre.count} genres created!"

puts 'Creating movies...'

(1..100).to_a.each do |page_index|
  # change 100 in 36885 to have all pages
  url_page = "#{url}&page=#{page_index}"
  movies_serialized = URI.open(url_page).read
  movies = JSON.parse(movies_serialized)['results']
  movies.each do |movie|
    new_movie = Movie.create(
      title: movie['title'],
      overview: movie['overview'],
      poster_url: movie['poster_path'].nil? ? '' : "https://image.tmdb.org/t/p/w500#{movie['poster_path']}",
      backdrop_url: movie['backdrop_path'].nil? ? '' : "https://image.tmdb.org/t/p/w1280#{movie['backdrop_path']}",
      rating: movie['vote_average'],
      release_date: movie['release_date'],
      api_id: movie['id'],
      popular: true
    )
    next if new_movie.id.nil?

    unless movie['genre_ids'].nil?
      movie['genre_ids'].each do |genre_id|
        MovieGenre.create(movie: new_movie, genre: Genre.find_by(api_id: genre_id)) unless genre_id.nil?
      end
    end

    url_movie = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}?api_key=#{api_key}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    new_movie.update(run_time: movie_details['runtime'], budget: movie_details['budget'], revenue: movie_details['revenue'])

    url_credits = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}/credits?api_key=#{api_key}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    crew = JSON.parse(credits_serialized)['crew']
    director = crew.find { |member| member['job'] == 'Director' }
    director_name = director.nil? ? '' : director['name']
    new_movie.update(director: director_name)
  end
  puts "#{Movie.count} movies created!"
end

puts 'Creating actors and casts...'

Movie.all.each do |movie|
  url_credits = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/credits?api_key=#{api_key}&language=en-US"
  credits_serialized = URI.open(url_credits).read
  credits = JSON.parse(credits_serialized)
  credits['cast'].each do |cast|
    actor = Actor.find_or_create_by(name: cast['name'], api_id: cast['id'])
    next if actor.id.nil?

    Cast.create(actor: actor,
                movie: movie,
                character: cast['character'],
                order: cast['order'],
                actor_api_id: cast['id'])
  end
  puts "#{Actor.count} actors created!"
  puts "#{Cast.count} casts created!"
end

puts 'Actors and casts created!'

puts 'Adding details to actors...'
Actor.all.each do |actor|
  url_actor = "https://api.themoviedb.org/3/person/#{actor[:api_id]}?api_key=#{api_key}&language=en-US"
  actor_details_serialized = URI.open(url_actor).read
  actor_details = JSON.parse(actor_details_serialized)
  actor.update(biography: actor_details['biography'],
               picture_url: actor_details['profile_path'].nil? ? '' : "https://image.tmdb.org/t/p/w780#{actor_details['profile_path']}")
  puts "#{actor.name} (#{actor.id}) updated!"
end

puts 'Details added to actors!'
puts "#{Actor.count} actors & #{Cast.count} casts created!"

puts 'Creating users...'
gwen = User.create(email: 'gwen@me.com', password: 'password')
puts '1 User created!'

puts 'Creating lists...'
fantastic = List.create(name: 'Fantastic', user_id: gwen.id)
horror = List.create(name: 'Horror', user_id: gwen.id)
action = List.create(name: 'Action', user_id: gwen.id)
puts "#{List.count} lists created!"

puts 'Creating bookmarks...'

Bookmark.create(movie: Movie.find_by(title: 'Avatar'), list: fantastic)
Bookmark.create(movie: Movie.find_by(title: 'Avatar: The Way of Water'), list: fantastic)
Bookmark.create(movie: Movie.find_by(title: 'The Batman'), list: fantastic)
puts "3 movies added to fantastic list!"

Bookmark.create(movie: Movie.find_by(title: 'Violent Night'), list: horror)
Bookmark.create(movie: Movie.find_by(title: 'M3GAN'), list: horror)
puts "2 movies added to horror list!"

Bookmark.create(movie: Movie.find_by(title: 'The Enforcer'), list: action)
puts "1 movie added to action list!"

puts 'Finished!'
