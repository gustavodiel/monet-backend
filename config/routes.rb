Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get :years, to: 'years#index'
  get 'years/:id', to: 'years#show'
  post :years, to: 'years#create'

  get :months, to: 'months#index'
  get 'months/:id', to: 'months#show'
  post :months, to: 'months#create'

  get :entries, to: 'entries#index'
  get 'entries/:id', to: 'entries#show'
  post :entries, to: 'entries#create'
end
