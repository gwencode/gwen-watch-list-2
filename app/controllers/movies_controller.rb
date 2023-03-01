# frozen_string_literal: true

require_relative '../services/movie_service'
require_relative '../services/genre_service'

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index parse_movies show]
  before_action :set_movie, only: %i[show]
  before_action :set_user, only: %i[show]

  def index
    # Initialize genres at first use in production
    GenreService.new.set_genres if Genre.all.empty?

    movie_service = MovieService.new

    # Initialize movies at first use in production
    # movie_service.init_prod

    # Select first page of movies
    popular_movies = Movie.where(popular: true, page_index: 1)

    if params[:page].present? && params[:query].present? && params[:genre].present?
      # Case when user filters by title, genre and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      title = params[:query]
      genre = Genre.find(params[:genre])
      new_movies = movie_service.parse_movies(@page_index, @page_index + 4) if @page_index + 4 < 500
      new_movies = new_movies.select { |movie| movie.title.downcase.include?(title.downcase) }
      new_movies = new_movies.select { |movie| movie.genres.include?(genre) }
      popular_movies += new_movies
      @movies = popular_movies.sort_by(&:page_index)
      render json: new_movies
    elsif params[:page].present? && params[:query].present? && params[:genre].blank?
      # Case when user filters by title and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      new_movies = movie_service.parse_movies(@page_index, @page_index + 4) if @page_index + 4 < 500
      new_movies = new_movies.select { |movie| movie.title.downcase.include?(params[:query].downcase) }
      popular_movies += new_movies
      @movies = popular_movies.sort_by(&:page_index)
      render json: new_movies
    elsif params[:page].present? && params[:genre].present? && params[:query].blank?
      # Case when user filters by genre and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      genre = Genre.find(params[:genre])
      new_movies = movie_service.parse_movies(@page_index, @page_index + 4) if @page_index + 4 < 500
      new_movies = new_movies.select { |movie| movie.genres.include?(genre) }
      popular_movies += new_movies
      @movies = popular_movies.sort_by(&:page_index)
      @page_index = @movies.max_by(&:page_index).page_index if @movies.any?
      render json: new_movies
    elsif params[:query].present? && params[:genre].present? && params[:page].blank?
      # Case when user filters by title and genre
      title = params[:query]
      genre = params[:genre].to_i
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").joins(:genres).where(genres: genre).limit(20).sort_by(&:page_index)
      @page_index = @movies.max_by(&:page_index).page_index if @movies.any?
    elsif params[:page].present? && params[:query].blank? && params[:genre].blank?
      # Case when user clicks on "Load more movies" button and no filters are applied
      @page_index = params[:page].to_i
      new_movies = movie_service.parse_movies(@page_index) if @page_index < 500
      popular_movies += new_movies
      @movies = popular_movies.sort_by(&:page_index)
      render json: new_movies
    elsif params[:query].present? && params[:genre].blank? && params[:page].blank?
      # Case when user filters by title and no load more movies button is clicked and no genre is selected
      title = params[:query]
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").limit(20).sort_by(&:page_index)
      @page_index = @movies.max_by(&:page_index).page_index if @movies.any?
    elsif params[:genre].present? && params[:query].blank? && params[:page].blank?
      # Case when user clicks on a genre and no search is applied and no load more movies button is clicked
      genre = params[:genre].to_i
      @movies = Movie.where(popular: true).joins(:genres).where(genres: genre).limit(20).sort_by(&:page_index)
      @page_index = @movies.max_by(&:page_index).page_index if @movies.any?
    else
      movie_service.parse_movies(1) # Update page 1 from the API
      # Render the first page of movies
      @movies = popular_movies.sort_by(&:page_index)
      @page_index = @movies.max_by(&:page_index).page_index if @movies.any?
      # Download a page of movies each time a user goes to the root page
      max_page_index = Movie.where(popular: true).max_by(&:page_index).page_index
      movie_service.parse_movies(max_page_index + 1) if max_page_index < 500
    end
    @movies_count = @movies.count
  end

  def show
    if current_user
      @bookmark = Bookmark.new
      @list = List.new(user_id: @user)
      @lists = @user.lists.where.not(id: Bookmark.where(movie: @movie).pluck(:list_id))
      # doc for pluck : https://apidock.com/rails/ActiveRecord/Calculations/pluck
    end
    MovieService.new.add_details(@movie)
    MovieService.new.add_director(@movie) if @movie.director.nil?
    MovieService.new.add_video(@movie) if @movie.video_id.nil?
    MovieService.new.parse_actors_casts(@movie) if @movie.actors.empty?
    @reco_movies = @movie.reco_movies
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def set_user
    @user = current_user
  end
end

### pluck documentation

# pluck(*column_names) public
# Use #pluck as a shortcut to select one or more attributes without loading a bunch of records just to grab the attributes you want.

# Person.pluck(:name)
# instead of

# Person.all.map(&:name)
# Pluck returns an Array of attribute values type-casted to match the plucked column names, if they can be deduced. Plucking an SQL fragment returns String values by default.

# Person.pluck(:name)
# # SELECT people.name FROM people
# # => ['David', 'Jeremy', 'Jose']

# Person.pluck(:id, :name)
# # SELECT people.id, people.name FROM people
# # => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]

# Person.distinct.pluck(:role)
# # SELECT DISTINCT role FROM people
# # => ['admin', 'member', 'guest']

# Person.where(age: 21).limit(5).pluck(:id)
# # SELECT people.id FROM people WHERE people.age = 21 LIMIT 5
# # => [2, 3]

# Person.pluck('DATEDIFF(updated_at, created_at)')
# # SELECT DATEDIFF(updated_at, created_at) FROM people
# # => ['0', '27761', '173']
