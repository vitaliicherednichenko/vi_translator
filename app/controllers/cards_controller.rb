class CardsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_collection
  before_action :set_card, only: %i[ show edit update destroy restore ]
  after_action :verify_authorized, except: %i[index practice]
  after_action :verify_policy_scoped, only: %i[index practice]

  # GET /cards or /cards.json
  def index
    @q = params[:q]
    @cards = policy_scope(@collection.cards).between_user_languages(current_user).search(@q)
  end

  # GET /collections/:collection_id/cards/practice
  # Writing-practice game: the cards are rendered into the page and a Stimulus
  # controller drives the quiz entirely client-side (one card at a time, shuffled).
  def practice
    @cards = policy_scope(@collection.cards).between_user_languages(current_user)
  end

  # GET /cards/1 or /cards/1.json
  def show
    authorize @card
  end

  # GET /cards/new
  def new
    @card = @collection.cards.new
    authorize @card
  end

  # GET /cards/1/edit
  def edit
    authorize @card
  end

  # POST /cards or /cards.json
  def create
    @card = @collection.cards.new(card_params)
    @card.user = current_user
    authorize @card

    respond_to do |format|
      if @card.save
        format.html { redirect_to collection_cards_path, notice: t("cards.flash.created") }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cards/1 or /cards/1.json
  def update
    authorize @card

    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to collection_cards_path, notice: t("cards.flash.updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /cards/1 or /cards/1.json
  def destroy
    authorize @card

    hard_delete = params[:hard].present? && (current_user&.admin? || @card.deleted?)

    if hard_delete
      @card.destroy!
      notice = t("cards.flash.permanently_deleted")
    else
      @card.soft_delete!
      notice = t("cards.flash.deleted")
    end

    respond_to do |format|
      format.html do
        redirect_back fallback_location: (hard_delete ? cards_path : collection_cards_path),
                      notice: notice, status: :see_other
      end
      format.json { head :no_content }
    end
  end

  # GET /collections/:collection_id/cards/export
  def export
    authorize @collection, :show?
    send_data CardsCsvExporter.new(current_user, collection: @collection).call,
              filename: "#{@collection.name.parameterize.presence || 'collection'}-#{Date.current.iso8601}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  # GET /collections/:collection_id/cards/import
  def import
    authorize @collection, :update?
  end

  # POST /collections/:collection_id/cards/import
  def run_import
    authorize @collection, :update?

    file = params[:file]
    unless file.respond_to?(:read)
      redirect_to import_collection_cards_path(@collection), alert: t("import.flash.no_file")
      return
    end

    result = CardsCsvImporter.new(current_user, file, collection: @collection).call

    if result.success?
      redirect_to collection_cards_path(@collection), notice: result.summary
    else
      redirect_to import_collection_cards_path(@collection), alert: result.error
    end
  end

  # DELETE /collections/:collection_id/cards/bulk
  def bulk_destroy
    authorize @collection, :update?

    ids = Array(params[:card_ids]).map(&:to_i).reject(&:zero?)
    scope = @collection.cards.kept.where(id: ids)
    count = scope.count
    scope.update_all(deleted_at: Time.current, updated_at: Time.current)

    redirect_to collection_cards_path(@collection),
                notice: t("cards.flash.bulk_deleted", count: count), status: :see_other
  end

  # PATCH /collections/:collection_id/cards/:id/restore
  def restore
    authorize @card
    @card.restore!

    respond_to do |format|
      format.html { redirect_to collection_cards_path, notice: t("cards.flash.restored"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_collection
      @collection = Collection.find(params[:collection_id])
    end

    def set_card
      @card = @collection.cards.find(params.expect(:id))
    end

    def card_params
      params.expect(card: [ :front_text, :back_text, :source_language_id, :target_language_id ])
    end
end
