# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'json'
require 'open-uri'

URL = ENV['API_URL']
API_KEY = ENV['API_KEY']

def clean_database
  puts 'Cleaning database...'
  Bookmark.destroy_all
  MovieGenre.destroy_all
  List.destroy_all
  User.destroy_all
  Cast.destroy_all
  Actor.destroy_all
  Movie.destroy_all
  Genre.destroy_all
  puts 'Database cleaned!'
end

def create_genres
  puts 'Creating genres...'

  url_genres = "https://api.themoviedb.org/3/genre/movie/list?api_key=#{API_KEY}&language=en-US"
  genres_serialized = URI.open(url_genres).read
  genres = JSON.parse(genres_serialized)['genres']
  genres.each do |genre|
    Genre.create(name: genre['name'], api_id: genre['id'])
  end

  puts "#{Genre.count} genres created!"
end

def parse_movies(start_page, end_page)
# 36885 pages (20 movies per page)
  puts 'Creating movies...'

  (start_page..end_page).to_a.each do |page_index|
    url_page = "#{URL}&page=#{page_index}"
    movies_serialized = URI.open(url_page).read
    movies = JSON.parse(movies_serialized)['results']
    movies.each do |movie|
      next if movie['poster_path'].nil? && movie['backdrop_path'].nil?

      new_movie = Movie.create(
        title: movie['title'],
        overview: movie['overview'],
        poster_url: movie['poster_path'].nil? ? '' : "https://image.tmdb.org/t/p/w400#{movie['poster_path']}",
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

      url_movie = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}?api_key=#{API_KEY}&language=en-US"
      movie_details_serialized = URI.open(url_movie).read
      movie_details = JSON.parse(movie_details_serialized)
      new_movie.update(run_time: movie_details['runtime'], budget: movie_details['budget'], revenue: movie_details['revenue'])

      url_credits = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
      credits_serialized = URI.open(url_credits).read
      crew = JSON.parse(credits_serialized)['crew']
      director = crew.find { |member| member['job'] == 'Director' }
      director_name = director.nil? ? '' : director['name']
      new_movie.update(director: director_name)
    end
    puts "#{Movie.count} movies created!"
  end
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
    url_credits = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    credits = JSON.parse(credits_serialized)
    max_10_casts = credits['cast'].first(10)
    max_10_casts.each do |cast|
      next if cast['profile_path'].nil?

      actor = Actor.find_or_create_by(name: cast['name'], api_id: cast['id'])
      next if actor.id.nil?

      Cast.create(actor: actor,
                  movie: movie,
                  character: cast['character'],
                  order: cast['order'],
                  actor_api_id: cast['id'])
    end
    puts "#{Actor.count} actors & #{Cast.count} casts created!"
  end
  puts 'Actors and casts created!'
end

def add_actor_details
  puts 'Adding details to actors...'
  Actor.all.each do |actor|
    url_actor = "https://api.themoviedb.org/3/person/#{actor[:api_id]}?api_key=#{API_KEY}&language=en-US"
    actor_details_serialized = URI.open(url_actor).read
    actor_details = JSON.parse(actor_details_serialized)
    actor.update(biography: actor_details['biography'],
                picture_url: "https://image.tmdb.org/t/p/w500/#{actor_details['profile_path']}")
    puts "#{actor.name} (#{actor.id}) updated!"
  end

  puts 'Details added to actors!'
  puts "#{Actor.count} actors & #{Cast.count} casts created!"
end

clean_database
create_genres
parse_movies(1, 2) # 40 movies
create_users_lists_bookmarks
parse_actors_casts
add_actor_details
puts 'First 40 movies created! You can start to work on localhost:3000!'

puts 'Wait for more movies and actors... Now creating more movies'
parse_movies(3, 100) # Change 100 to 36885 pages to have all movies (20 movies per page)
parse_actors_casts
add_actor_details

puts 'Finished!'
