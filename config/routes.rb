# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'movies#index'
  resources :movies, only: %i[show]
  resources :lists, only: %i[index show new create] do
    resources :bookmarks, only: %i[create]
  end
end
