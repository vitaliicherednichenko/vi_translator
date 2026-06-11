class AllCardsController < ApplicationController
  before_action :authenticate_user!, only: %i[deleted export import run_import add_to_collection]

  def index
    @cards = Card.between_user_languages(current_user)
             .original
             .includes(:collection, :source_language, :target_language)
             .order(created_at: :desc)
    @my_collections =
      current_user&.collections&.in_user_native_language(current_user)&.order(:name)&.to_a || []
  end

  # POST /cards/:id/add_to_collection
  def add_to_collection
    source = Card.find(params[:id])
    collection = current_user.collections.find_by(id: params[:collection_id])

    unless collection
      redirect_back fallback_location: cards_path, alert: "Choose one of your collections to add this card to."
      return
    end

    card = current_user.cards.find_or_create_by!(
      collection: collection,
      front_text: source.front_text,
      back_text: source.back_text,
      source_language_id: source.source_language_id,
      target_language_id: source.target_language_id
    ) { |c| c.copied_from = (source.copied_from || source) }

    notice =
      if card.previously_new_record?
        "Added \"#{card.front_text}\" to #{collection.name}."
      else
        "\"#{card.front_text}\" is already in #{collection.name}."
      end

    redirect_back fallback_location: cards_path, notice: notice
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
