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
Movie.destroy_all

url = ENV['API_URL']

(1..5).to_a.each do |page_index|
  # change 5 in 36885 to have all pages
  url_page = "#{url}&page=#{page_index}"
  movies_serialized = URI.open(url_page).read
  movies = JSON.parse(movies_serialized)['results']
  movies.each do |movie|
    Movie.create(
      title: movie['title'],
      overview: movie['overview'],
      poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}",
      backdrop_url: "https://image.tmdb.org/t/p/w500#{movie['backdrop_path']}",
      rating: movie['vote_average']
    )
  end
  puts "#{Movie.all.count} movies created!"
end
