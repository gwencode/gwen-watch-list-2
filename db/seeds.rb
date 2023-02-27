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

def create_users
  puts 'Creating users...'
  User.create(email: 'gwen@me.com', password: 'password')
  puts "#{User.count} users created!"
end

clean_database
create_users

puts 'Finished!'
