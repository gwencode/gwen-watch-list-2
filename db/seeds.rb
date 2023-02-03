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
Cast.destroy_all
Actor.destroy_all
Movie.destroy_all

url = ENV['API_URL']
api_key = ENV['API_KEY']

puts 'Creating movies...'

(1..1).to_a.each do |page_index|
  # change 1 in 36885 to have all pages
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
    url_movie = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}?api_key=#{api_key}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    new_movie.update(run_time: movie_details['runtime'], budget: movie_details['budget'], revenue: movie_details['revenue'])

    url_credits = "https://api.themoviedb.org/3/movie/#{new_movie[:api_id]}/credits?api_key=#{api_key}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    crew = JSON.parse(credits_serialized)['crew']
    director = crew.find { |member| member['job'] == 'Director' }['name']
    new_movie.update(director: director)
  end
  puts "#{Movie.all.count} movies created!"
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
end

puts 'Actors and casts created!'

puts 'Adding details to actors...'
Actor.all.each do |actor|
  url_actor = "https://api.themoviedb.org/3/person/#{actor[:api_id]}?api_key=#{api_key}&language=en-US"
  actor_details_serialized = URI.open(url_actor).read
  actor_details = JSON.parse(actor_details_serialized)
  actor.update(biography: actor_details['biography'],
               picture_url: actor_details['profile_path'].nil? ? '' : "https://image.tmdb.org/t/p/w780#{actor_details['profile_path']}")
end

puts 'Details added to actors!'
puts "#{Actor.all.count} actors & #{Cast.all.count} casts created!"
