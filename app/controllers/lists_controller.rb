# frozen_string_literal: true

# Controller for the List model
class ListsController < ApplicationController
  before_action :set_list, only: %i[show destroy update]
  before_action :set_user

  def index
    @lists = @user.lists
  end

  def show
  end

  def create
    name = list_params[:name]
    movie_id = list_params[:movie_id].to_i

    list = List.new(name: name, user_id: @user.id)
    if list.save
      bookmark = Bookmark.new(list: list, movie_id: movie_id)
      if bookmark.save
        redirect_to list_path(list)
      else
        render 'movies/show'
      end
    else
      render 'movies/show'
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
