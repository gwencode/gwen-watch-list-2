# frozen_string_literal: true
require_relative '../services/movie_service'

# Controller for the List model
class ListsController < ApplicationController
  before_action :set_list, only: %i[show destroy update]
  before_action :set_user

  def index
    @lists = @user.lists

    # Update a random page of movies each time a user goes to this page
    movies = MovieService.new.parse_movies(rand(1..500))
    puts "_______________________________________________________"
    puts "Movies updated: #{movies.count}"
    puts "Movies page: #{movies.first.page_index}"
  end

  def show
    if @list.user_id != current_user.id
      flash[:alert] = "You don't have access to this page"
      redirect_to root_path
    end
  end

  def create
    name = list_params[:name]
    movie_id = list_params[:movie_id].to_i
    @movie = Movie.find(movie_id)
    list = List.new(name: name, user_id: @user.id)

    if List.exists?(name: name, user_id: @user.id)
      flash[:error] = 'Name already taken'
      redirect_to movie_path(@movie)
    elsif list.save
      bookmark = Bookmark.new(list: list, movie_id: movie_id)
      if bookmark.save
        redirect_to list_path(list)
      else
        redirect_to movie_path(@movie)
      end
    else
      redirect_to movie_path(@movie)
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_path
  end

  def update
    new_name = list_params[:name]
    @list.update(name: new_name)
    redirect_to list_path(@list)
  end

  private

  def list_params
    params.require(:list).permit(:name, :movie_id)
  end

  def set_user
    @user = current_user
  end

  def set_list
    @list = List.find(params[:id])
  end
end
