# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/show'
  get 'my_movies/index'
  devise_for :users
  # get 'actors/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'movies#index'
  resources :movies, only: %i[show] do
    resources :bookmarks, only: %i[create destroy]
  end
  resources :actors, only: %i[index show]
  resources :lists, only: %i[index show create destroy update]
  resources :my_movies, only: %i[index]
  resources :users, only: %i[show]
end
