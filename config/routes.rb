Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'
  delete '/intuit/revoke', to: 'intuit#revoke', as: 'revoke_intuit'
  get '/intuit/oauth', to: 'intuit#oauth'
  match '/intuit/gateway/*path', to: 'intuit#gateway', via: [:get, :post]
end
