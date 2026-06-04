class CollectionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_collection, only: %i[ show edit update destroy ]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /collections or /collections.json
  def index
    @collections = policy_scope(Collection).in_user_native_language(current_user)
  end

  # GET /collections/1 or /collections/1.json
  def show
    authorize @collection
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    authorize @collection
  end

  # GET /collections/1/edit
  def edit
    authorize @collection
  end

  # POST /collections or /collections.json
  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user
    authorize @collection

    if @collection.save
      redirect_to @collection, notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    authorize @collection

    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: "Collection was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @collection.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    authorize @collection
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to collections_path, notice: "Collection was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through. The owner is always the
    # current user, so user_id is never accepted from the request.
    def collection_params
      params.expect(collection: [ :name, :description, :language_id ])
    end
end
