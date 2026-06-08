Rails.application.routes.draw do
  resources :languages

  devise_for :users, path: 'auth', path_names: {
    sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock',
    registration: 'register', sign_up: 'cmon_let_me_in'
  }

  resources :cards, only: [ :index ], controller: "all_cards"
  get "cards/deleted", to: "all_cards#deleted", as: :deleted_cards
  get "cards/export", to: "all_cards#export", as: :export_cards
  get "cards/import", to: "all_cards#import", as: :import_cards
  post "cards/import", to: "all_cards#run_import"

  resources :collections do
    resources :cards do
      member { patch :restore }
    end
  end

  root "collections#index"
end
