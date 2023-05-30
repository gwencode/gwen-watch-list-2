require_relative '../app/services/genre_service'
require_relative '../app/services/movie_service'
require_relative '../app/services/actor_service'

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
  GenreService.new.set_genres
  puts "#{Genre.count} genres created!"
end

def create_movies
  puts 'Creating popular movies...'
  MovieService.new.parse_movies(1, 500)
  puts "#{Movie.where(popular: true).count} popular movies created!"
end

def create_actors_casts
  puts 'Creating actors and casts...'
  Movie.where(popular: true).each do |movie|
    next if Actor.count >= 10000

    MovieService.new.parse_actors_casts(movie)
    puts "#{Actor.count} actors created!"
    puts "#{Cast.count} casts created!"
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
  puts "#{fantastic.movies.count} movies added to fantastic list of Gwendal!"
  Bookmark.create(movie: Movie.find_by(title: 'Violent Night'), list: horror)
  Bookmark.create(movie: Movie.find_by(title: 'M3GAN'), list: horror)
  puts "#{horror.movies.count} movies added to horror list of Gwendal!"
  Bookmark.create(movie: Movie.find_by(title: 'The Enforcer'), list: action)
  puts "#{action.movies.count} movie added to action list of Gwendal!"
  Bookmark.create(movie: Movie.find_by(title: 'Black Panther: Wakanda Forever'), list: superhero)
  Bookmark.create(movie: Movie.find_by(title: 'Black Adam'), list: superhero)
  puts "#{superhero.movies.count} movies added to superhero list of John!"
end

# clean_database

# puts 'Starting to seed...'

# create_genres
# create_movies
create_actors_casts
create_users_lists_bookmarks

puts 'Finished!'
