Rails.application.routes.draw do
  # Health check endpoint used by the Kamal proxy (and load balancers/uptime monitors).
  get "up" => "rails/health#show", as: :rails_health_check

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
  post "cards/:id/add_to_collection", to: "all_cards#add_to_collection", as: :add_card_to_collection
  delete "cards/bulk", to: "all_cards#bulk_destroy", as: :bulk_cards

  resources :collections do
    resources :cards do
      member { patch :restore }
      collection do
        get    "export", to: "cards#export"
        get    "import", to: "cards#import"
        post   "import", to: "cards#run_import"
        delete "bulk",   to: "cards#bulk_destroy"
      end
    end
  end

  root "collections#index"
end
