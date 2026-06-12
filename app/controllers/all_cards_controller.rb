class AllCardsController < ApplicationController
  before_action :authenticate_user!, only: %i[deleted export import run_import add_to_collection bulk_destroy]

  def index
    @cards = Card.between_user_languages(current_user)
             .original
             .includes(:collection, :source_language, :target_language)
             .order(created_at: :desc)
    @my_collections =
      current_user&.collections&.in_user_languages(current_user)&.order(:name)&.to_a || []
  end

  # POST /cards/:id/add_to_collection
  def add_to_collection
    source = Card.find(params[:id])
    collection = current_user.collections.find_by(id: params[:collection_id])

    unless collection
      redirect_back fallback_location: cards_path, alert: t("cards.flash.choose_collection")
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
        t("cards.flash.added", card: card.front_text, collection: collection.name)
      else
        t("cards.flash.already_present", card: card.front_text, collection: collection.name)
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
      redirect_to import_cards_path, alert: t("import.flash.no_file")
      return
    end

    result = CardsCsvImporter.new(current_user, file).call

    if result.success?
      redirect_to cards_path, notice: result.summary
    else
      redirect_to import_cards_path, alert: result.error
    end
  end

  def bulk_destroy
    unless current_user.admin?
      redirect_to cards_path, alert: t("flash.not_authorized")
      return
    end

    ids = Array(params[:card_ids]).map(&:to_i).reject(&:zero?)
    count = Card.where(id: ids).destroy_all.size

    redirect_to cards_path, notice: t("cards.flash.bulk_deleted", count: count), status: :see_other
  end
end
