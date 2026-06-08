class AllCardsController < ApplicationController
  before_action :authenticate_user!, only: :deleted
  after_action :verify_policy_scoped, only: :index

  # GET /cards
  def index
    @cards = policy_scope(Card)
             .between_user_languages(current_user)
             .includes(:collection, :source_language, :target_language)
             .order(created_at: :desc)
  end

  # GET /cards/deleted — the current user's soft-deleted ("removed") cards.
  def deleted
    @cards = current_user.cards.deleted
             .includes(:collection, :source_language, :target_language)
             .order(deleted_at: :desc)
  end
end
