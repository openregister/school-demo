Rails.application.routes.draw do

  resources :schools, only: [:show]

  resources :items, only: [:show, :index]

  resources :points, only: [:show], constraints: { id: /[^\/]+/ }

end
