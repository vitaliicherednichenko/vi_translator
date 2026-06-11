class CardsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_collection
  before_action :set_card, only: %i[ show edit update destroy restore ]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /cards or /cards.json
  def index
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
    @card.soft_delete!

    respond_to do |format|
      format.html { redirect_to collection_cards_path, notice: t("cards.flash.deleted"), status: :see_other }
      format.json { head :no_content }
    end
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
