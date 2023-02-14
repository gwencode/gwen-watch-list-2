require "json"
require "open-uri"
API_KEY = ENV['API_KEY']

class MovieService
  def initialize(movie)
    @movie = movie
  end

  def add_details
    url_movie = "https://api.themoviedb.org/3/movie/#{@movie[:api_id]}?api_key=#{API_KEY}&language=en-US"
    movie_details_serialized = URI.open(url_movie).read
    movie_details = JSON.parse(movie_details_serialized)
    @movie.update(overview: movie_details['overview'],
                 backdrop_url: movie_details['backdrop_path'].nil? ? '' : "https://image.tmdb.org/t/p/w1280#{movie_details['backdrop_path']}",
                 release_date: movie_details['release_date'],
                 run_time: movie_details['runtime'],
                 budget: movie_details['budget'],
                 revenue: movie_details['revenue'],
                 rating: movie_details['vote_average'])
  end

  def add_video
    url_videos = "https://api.themoviedb.org/3/movie/#{@movie[:api_id]}/videos?api_key=#{API_KEY}&language=en-US"
    videos_details_serialized = URI.open(url_videos).read
    videos_details = JSON.parse(videos_details_serialized)
    videos = videos_details['results']
    # find the first video that is a trailer
    video_details = videos.find { |video| video['type'] == 'Trailer' }
    @movie.update(video_id: video_details['key']) if video_details
  end

  def add_director
    url_credits = "https://api.themoviedb.org/3/movie/#{@movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
    credits_serialized = URI.open(url_credits).read
    crew = JSON.parse(credits_serialized)['crew']
    director = crew.find { |member| member['job'] == 'Director' }
    director_name = director.nil? ? '' : director['name']
    @movie.update(director: director_name)
  end

  def parse_actors_casts
    url_credits = "https://api.themoviedb.org/3/movie/#{@movie[:api_id]}/credits?api_key=#{API_KEY}&language=en-US"
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
                  movie: @movie,
                  character: cast['character'],
                  order: cast['order'],
                  actor_api_id: cast['id'])
    end
  end
end
