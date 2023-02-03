# frozen_string_literal: true

# Controller for the List model
class ListsController < ApplicationController
  before_action :set_list, only: %i[show]
  before_action :set_user

  def index
    @lists = @user.lists
  end

  def show
  end

  def new
    @list = List.new(user: @user)
  end

  def create
    @list = List.new(list_params)
    if @list.save
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :user_id)
  end

  def set_user
    @user = current_user
  end

  def set_list
    @list = List.find(params[:id])
  end
end
