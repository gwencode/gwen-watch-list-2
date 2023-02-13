# frozen_string_literal: true

# Controller for the Movie model
class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_movie, only: %i[show]
  before_action :set_user, only: %i[show]

  def index
    popular_movies = Movie.where(popular: true)
    if params[:query].present?
      popular_movies = popular_movies.where('title ILIKE ?', "%#{params[:query]}%")
    end

    if params[:genre].present?
      popular_movies = popular_movies.joins(:genres).where(genres: { id: params[:genre].to_i })
    end

    @movies = popular_movies.sort_by { |movie| movie.id }
  end

  def show
    if current_user
      @bookmark = Bookmark.new
      @list = List.new(user_id: @user)
      @lists = @user.lists.where.not(id: Bookmark.where(movie: @movie).pluck(:list_id))
      # doc for pluck : https://apidock.com/rails/ActiveRecord/Calculations/pluck
    end
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
