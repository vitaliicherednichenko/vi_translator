Rails.application.routes.draw do
  resources :languages

  devise_for :users, path: 'auth', path_names: {
    sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock',
    registration: 'register', sign_up: 'cmon_let_me_in'
  }

  resources :cards, only: [ :index ], controller: "all_cards"

  resources :collections do
    resources :cards
  end

  root "collections#index"
end
