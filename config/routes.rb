Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'
  get '/intuit/oauth', to: 'intuit#oauth'
  match '/intuit/gateway/*', to: 'intuit#gateway', via: [:get, :post]
end
