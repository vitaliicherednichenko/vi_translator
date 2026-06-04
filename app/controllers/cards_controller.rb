class CardsController < ApplicationController
  before_action :set_collection
  before_action :set_card, only: %i[ show edit update destroy ]

  # GET /cards or /cards.json
  def index
    @cards = @collection.cards
  end

  # GET /cards/1 or /cards/1.json
  def show
  end

  # GET /cards/new
  def new
    @card = Card.new
  end

  # GET /cards/1/edit
  def edit
  end

  # POST /cards or /cards.json
  def create
    @card = Card.new(card_params)

    respond_to do |format|
      if @card.save
        format.html { redirect_to collection_cards_path, notice: "Card was successfully created." }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cards/1 or /cards/1.json
  def update
    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to collection_cards_path, notice: "Card was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @card.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /cards/1 or /cards/1.json
  def destroy
    @card.destroy!

    respond_to do |format|
      format.html { redirect_to collection_cards_path, notice: "Card was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_collection
      @collection = Collection.find(params[:collection_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def card_params
      params.expect(card: [ :front_text, :back_text, :user_id, :collection_id, :source_language_id, :target_language_id ])
    end
end
