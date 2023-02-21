require 'json'
require 'open-uri'
require_relative '../app/services/movie_service'

URL = ENV['API_URL']
API_KEY = ENV['API_KEY']

def clean_database
  puts 'Cleaning database...'
  Bookmark.destroy_all
  List.destroy_all
  User.destroy_all
  Cast.destroy_all
  Actor.destroy_all
  Movie.destroy_all
  puts 'Database cleaned!'
end

def create_users_lists_bookmarks
  puts 'Creating users...'
  gwen = User.create(email: 'gwen@me.com', password: 'password')
  john = User.create(email: 'john@me.com', password: 'password')
  puts "#{User.count} users created!"

  puts 'Creating lists...'
  fantastic = List.create(name: 'Fantastic', user_id: gwen.id)
  horror = List.create(name: 'Horror', user_id: gwen.id)
  action = List.create(name: 'Action', user_id: gwen.id)
  superhero = List.create(name: 'Superhero', user_id: john.id)
  puts "#{List.count} lists created!"

  puts 'Creating bookmarks...'

  Bookmark.create(movie: Movie.find_by(title: 'Avatar'), list: fantastic)
  Bookmark.create(movie: Movie.find_by(title: 'Avatar: The Way of Water'), list: fantastic)
  Bookmark.create(movie: Movie.find_by(title: 'Black Adam'), list: fantastic)
  puts '3 movies added to fantastic list of Gwendal!'

  Bookmark.create(movie: Movie.find_by(title: 'Violent Night'), list: horror)
  Bookmark.create(movie: Movie.find_by(title: 'M3GAN'), list: horror)
  puts '2 movies added to horror list of Gwendal!'

  Bookmark.create(movie: Movie.find_by(title: 'The Enforcer'), list: action)
  puts '1 movie added to action list of Gwendal!'

  Bookmark.create(movie: Movie.find_by(title: 'Black Panther: Wakanda Forever'), list: superhero)
  Bookmark.create(movie: Movie.find_by(title: 'Black Adam'), list: superhero)
  puts '2 movies added to superhero list of John!'
end

def parse_actors_casts
  puts 'Creating actors and max 10 casts per movie...'
  Movie.all.each do |movie|
    MovieService.new(movie).parse_actors_casts
    puts "#{Actor.count} actors & #{Cast.count} casts created!"
  end
  puts 'Actors and casts created!'
end

clean_database
create_genres
parse_movies(1, 2) # 40 movies
create_users_lists_bookmarks
parse_actors_casts
puts 'First 40 movies created! You can start to work on localhost:3000!'

puts 'Wait for more movies and actors... Now creating more movies'
parse_movies(3, 500) # after 501 => OpenURI::HTTPError: 422 Unknown / "page must be less than or equal to 500"
parse_actors_casts

puts 'Finished!'
