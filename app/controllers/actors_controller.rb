class ActorsController < ApplicationController
  before_action :set_actor, only: [:show]

  def show
  end

  private

  def set_actor
    @actor = Actor.find(params[:id])
  end
end
