# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Lundi, mercredi, vendredi
every '0 1 * * 1,3,5' do
  runner "MovieService.parse_movies(1, 50)"
end

every '0 2 * * 1,3,5' do
  runner "MovieService.parse_movies(51, 100)"
end

every '0 3 * * 1,3,5'do
  runner "MovieService.parse_movies(101, 150)"
end

every '0 4 * * 1,3,5' do
  runner "MovieService.parse_movies(151, 200)"
end

every '0 5 * * 1,3,5' do
  runner "MovieService.parse_movies(201, 250)"
end

# Mardi, jeudi, samedi
every '0 1 * * 2,4,6' do
  runner "MovieService.parse_movies(251, 300)"
end

every '0 2 * * 2,4,6' do
  runner "MovieService.parse_movies(301, 350)"
end

every '0 3 * * 2,4,6' do
  runner "MovieService.parse_movies(351, 400)"
end

every '0 4 * * 2,4,6' do
  runner "MovieService.parse_movies(401, 450)"
end

every '0 5 * * 2,4,6' do
  runner "MovieService.parse_movies(451, 500)"
end

# Tous les jours
every 1.minute do
  runner "MovieService.parse_actors_random_movie"
end
