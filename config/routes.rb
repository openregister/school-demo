Rails.application.routes.draw do

  root to: 'items#index'

  resources :schools, only: [:show]

  resources :items, only: [:show, :index]

  resources :points, only: [:show], constraints: { id: /[^\/]+/ }

end
