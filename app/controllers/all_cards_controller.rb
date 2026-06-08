class AllCardsController < ApplicationController
  before_action :authenticate_user!, only: %i[deleted export import run_import]
  after_action :verify_policy_scoped, only: :index

  # GET /cards
  def index
    @cards = policy_scope(Card)
             .between_user_languages(current_user)
             .includes(:collection, :source_language, :target_language)
             .order(created_at: :desc)
  end

  # GET /cards/deleted
  def deleted
    @cards = current_user.cards.deleted
             .includes(:collection, :source_language, :target_language)
             .order(deleted_at: :desc)
  end

  # GET /cards/export
  def export
    send_data CardsCsvExporter.new(current_user).call,
              filename: "cards-#{Date.current.iso8601}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  # GET /cards/import
  def import; end

  # POST /cards/import
  def run_import
    file = params[:file]
    unless file.respond_to?(:read)
      redirect_to import_cards_path, alert: "Please choose a CSV file to import."
      return
    end

    result = CardsCsvImporter.new(current_user, file).call

    if result.success?
      redirect_to cards_path, notice: result.summary
    else
      redirect_to import_cards_path, alert: result.error
    end
  end
end
