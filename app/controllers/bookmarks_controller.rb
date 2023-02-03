# frozen_string_literal: true

# Controller for the Bookmark model
class BookmarksController < ApplicationController
  before_action :set_movie, only: %i[create]

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.movie = @movie
    if @bookmark.save
      redirect_to list_path(@bookmark.list)
    else
      render 'movies/show', status: :unprocessable_entity
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def bookmark_params
    params.require(:bookmark).permit(:list_id, :movie_id)
  end
end
