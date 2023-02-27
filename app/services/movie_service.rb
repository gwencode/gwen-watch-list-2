require "json"
require "open-uri"
API_KEY = ENV['API_KEY']
URL = ENV['API_URL']

class MovieService
  def parse_movies(page_start, page_end = page_start)
    # 500 pages (20 movies per page)
    new_movies = []
    (page_start..page_end).each do |page_index|
      url_page = "#{URL}&page=#{page_index}"
      movies_serialized = URI.open(url_page).read
      page_index = JSON.parse(movies_serialized)['page'].to_i
      movies = JSON.parse(movies_serialized)['results']
      movies.each do |movie|
        next if movie['poster_path'].nil? && movie['backdrop_path'].nil?

        new_movie = Movie.find_or_create_by(title: movie['title'], api_id: movie['id'])

        new_movie.update(
          poster_url: movie['poster_path'].nil? ? '' : "https://image.tmdb.org/t/p/w400#{movie['poster_path']}",
          popular: true,
          page_index: page_index)

        next if new_movie.id.nil?

        unless movie['genre_ids'].nil?
          movie['genre_ids'].each do |genre_id|
            MovieGenre.find_or_create_by(movie: new_movie, genre: Genre.find_by(api_id: genre_id)) unless genre_id.nil?
          end
        end
        new_movies << new_movie
      end
    end
    new_movies
  end

  def add_biography(movie)
    url_movie = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}?api_key=#{API_KEY}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    movie.update(overview: movie_details['overview'])
  end

  def add_details(movie)
    url_movie = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}?api_key=#{API_KEY}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    movie.update(overview: movie_details['overview'],
                 backdrop_url: movie_details['backdrop_path'].nil? ? '' : "https://image.tmdb.org/t/p/w1280#{movie_details['backdrop_path']}",
                 release_date: movie_details['release_date'],
                 run_time: movie_details['runtime'],
                 budget: movie_details['budget'],
                 revenue: movie_details['revenue'],
                 rating: movie_details['vote_average'])
  end

  def add_video(movie)
    url_videos = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/videos?api_key=#{API_KEY}&language=en-US"
    videos_details_serialized = URI.open(url_videos).read
    videos_details = JSON.parse(videos_details_serialized)
    videos = videos_details['results']
    # find the first video that is a trailer
    video_details = videos.find { |video| video['type'] == 'Trailer' }
    movie.update(video_id: video_details['key']) if video_details
  end

  def add_director(movie)
    url_credits = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    crew = JSON.parse(credits_serialized)['crew']
    director = crew.find { |member| member['job'] == 'Director' }
    director_name = director.nil? ? '' : director['name']
    movie.update(director: director_name)
  end

  def parse_actors_casts(movie)
    url_credits = "https://api.themoviedb.org/3/movie/#{movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    credits = JSON.parse(credits_serialized)
    max_10_casts = credits['cast'].first(10)
    max_10_casts.each do |cast|
      next if cast['profile_path'].nil?

      actor = Actor.find_or_create_by(name: cast['name'],
                                      api_id: cast['id'],
                                      picture_url: "https://image.tmdb.org/t/p/w500#{cast['profile_path']}")
      next if actor.id.nil?

      Cast.create(actor: actor,
                  movie: movie,
                  character: cast['character'],
                  order: cast['order'],
                  actor_api_id: cast['id'])
    end
  end
end
