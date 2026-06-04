class AllCardsController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  # GET /cards
  def index
    @cards = policy_scope(Card)
             .between_user_languages(current_user)
             .includes(:collection, :source_language, :target_language)
             .order(created_at: :desc)
  end
end
