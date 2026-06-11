class LanguagesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_language, only: %i[ show edit update destroy ]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /languages or /languages.json
  def index
    @languages = policy_scope(Language)
  end

  # GET /languages/1 or /languages/1.json
  def show
    authorize @language
  end

  # GET /languages/new
  def new
    @language = Language.new
    authorize @language
  end

  # GET /languages/1/edit
  def edit
    authorize @language
  end

  # POST /languages or /languages.json
  def create
    @language = Language.new(language_params)
    authorize @language

    respond_to do |format|
      if @language.save
        format.html { redirect_to @language, notice: t("languages.flash.created") }
        format.json { render :show, status: :created, location: @language }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @language.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /languages/1 or /languages/1.json
  def update
    authorize @language

    respond_to do |format|
      if @language.update(language_params)
        format.html { redirect_to @language, notice: t("languages.flash.updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @language }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @language.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /languages/1 or /languages/1.json
  def destroy
    authorize @language
    @language.destroy!

    respond_to do |format|
      format.html { redirect_to languages_path, notice: t("languages.flash.destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language
      @language = Language.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def language_params
      params.expect(language: [ :name, :code, :native_name ])
    end
end
