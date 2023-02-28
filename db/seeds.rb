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

def create_user
  puts 'Creating user...'
  User.create(email: 'gwen@me.com', password: 'password')
  puts "#{User.count} user created!"
end

clean_database
create_user

puts 'Finished!'
