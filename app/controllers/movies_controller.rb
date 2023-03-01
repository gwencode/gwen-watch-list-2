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

    # Initialize movies at first use in production
    # MovieService.new.init_prod

    if params[:page].present? && params[:query].present? && params[:genre].present?
      # Case when user filters by title, genre and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      title = params[:query]
      genre = params[:genre].to_i
      @movies_count = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").joins(:genres).where(genres: genre).count
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").joins(:genres).where(genres: genre).sort_by(&:page_index).first(20 * @page_index)
      last_movies = @movies_count > 20 * @page_index ? @movies.last(20) : @movies.last(@movies_count - 20 * (@page_index - 1))
      render json: last_movies

    elsif params[:page].present? && params[:query].present? && params[:genre].blank?
      # Case when user filters by title and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      title = params[:query]
      @movies_count = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").count
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").sort_by(&:page_index).first(20 * @page_index)
      last_movies = @movies_count > 20 * @page_index ? @movies.last(20) : @movies.last(@movies_count - 20 * (@page_index - 1))
      render json: last_movies
    elsif params[:page].present? && params[:genre].present? && params[:query].blank?
      # Case when user filters by genre and clicks on "Load more movies" button
      @page_index = params[:page].to_i
      genre = Genre.find(params[:genre])
      @movies_count = Movie.where(popular: true).joins(:genres).where(genres: genre).count
      @movies = Movie.where(popular: true).joins(:genres).where(genres: genre).sort_by(&:page_index).first(20 * @page_index)
      last_movies = @movies_count > 20 * @page_index ? @movies.last(20) : @movies.last(@movies_count - 20 * (@page_index - 1))
      render json: last_movies
    elsif params[:query].present? && params[:genre].present? && params[:page].blank?
      # Case when user filters by title and genre
      title = params[:query]
      genre = params[:genre].to_i
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").joins(:genres).where(genres: genre).sort_by(&:page_index).first(20)
      @page_index = 1
      @movies_count = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").joins(:genres).where(genres: genre).count
    elsif params[:page].present? && params[:query].blank? && params[:genre].blank?
      # Case when user clicks on "Load more movies" button and no filters are applied
      @page_index = params[:page].to_i
      new_movies = @page_index < 500 ? Movie.where(popular: true, page_index: @page_index) : []
      render json: new_movies
    elsif params[:query].present? && params[:genre].blank? && params[:page].blank?
      # Case when user filters by title and no load more movies button is clicked and no genre is selected
      title = params[:query]
      @movies = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").sort_by(&:page_index).first(20)
      @page_index = 1
      @movies_count = Movie.where(popular: true).where('title ILIKE ?', "%#{title}%").count
    elsif params[:genre].present? && params[:query].blank? && params[:page].blank?
      # Case when user clicks on a genre and no search is applied and no load more movies button is clicked
      genre = params[:genre].to_i
      @movies = Movie.where(popular: true).joins(:genres).where(genres: genre).sort_by(&:page_index).first(20)
      @page_index = 1
      @movies_count = Movie.where(popular: true).joins(:genres).where(genres: genre).count
    else
      movie_service = MovieService.new
      movie_service.parse_movies(1) # Update page 1 from the API
      # Render the first page of movies
      @movies = Movie.where(popular: true, page_index: 1)
      @page_index = 1
      @movies_count = Movie.where(popular: true).count

      # Download a page of movies each time a user goes to the root page if not all pages are downloaded
      max_page_index = Movie.where(popular: true).max_by(&:page_index).page_index
      movie_service.parse_movies(max_page_index) if Movie.where(popular: true, page_index: max_page_index).count <= 10
      movie_service.parse_movies(max_page_index + 1) if max_page_index < 500
    end
  end

  def show
    if current_user
      @bookmark = Bookmark.new
      @list = List.new(user_id: @user)
      @lists = @user.lists.where.not(id: Bookmark.where(movie: @movie).pluck(:list_id))
      # doc for pluck : https://apidock.com/rails/ActiveRecord/Calculations/pluck
    end
    movie_service = MovieService.new
    movie_service.add_details(@movie)
    movie_service.add_director(@movie) if @movie.director.nil?
    movie_service.add_video(@movie) if @movie.video_id.nil?
    movie_service.parse_actors_casts(@movie) if @movie.actors.empty?
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
