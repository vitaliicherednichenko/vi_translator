require 'rails_helper'

RSpec.describe "/collections", type: :request do
  let(:en) { create(:language) }
  let(:owner) { create(:user, native_language: en) }
  let(:other) { create(:user, native_language: en) }
  let(:admin) { create(:user, :admin, native_language: en) }
  let!(:collection) { create(:collection, user: owner, language: en) }
  let(:valid_attributes)   { { name: "My Set", description: "desc", language_id: en.id } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET /index" do
    it "renders for everyone" do
      get collections_url
      expect(response).to be_successful
    end

    it "shows collections in either the user's native or preferred language" do
      es = create(:language)
      fr = create(:language)
      english_collection = create(:collection, user: other, language: en, name: "english-set")
      spanish_collection = create(:collection, user: other, language: es, name: "spanish-set")
      french_collection  = create(:collection, user: other, language: fr, name: "french-set")

      owner.update!(native_language: en, preferred_language: es)
      sign_in owner
      get collections_url

      # native (en) and preferred (es) both shown, regardless of pair direction
      expect(response.body).to include("english-set")
      expect(response.body).to include("spanish-set")
      # a language that is neither stays hidden
      expect(response.body).not_to include("french-set")
      expect(response.body).not_to include(ActionView::RecordIdentifier.dom_id(french_collection))
      expect(response.body).to include(ActionView::RecordIdentifier.dom_id(english_collection))
      expect(response.body).to include(ActionView::RecordIdentifier.dom_id(spanish_collection))
    end
  end

  describe "GET /show" do
    it "renders for everyone" do
      get collection_url(collection)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders for a signed-in user" do
      sign_in owner
      get new_collection_url
      expect(response).to be_successful
    end

    it "redirects a guest to login" do
      get new_collection_url
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /create" do
    it "creates a collection owned by the current user" do
      sign_in owner
      expect {
        post collections_url, params: { collection: valid_attributes }
      }.to change(Collection, :count).by(1)
      expect(Collection.last.user).to eq(owner)
      expect(response).to redirect_to(collection_url(Collection.last))
    end

    it "does not create with invalid params" do
      sign_in owner
      expect {
        post collections_url, params: { collection: invalid_attributes }
      }.not_to change(Collection, :count)
      expect(response).to have_http_status(422)
    end

    it "redirects a guest to login" do
      expect {
        post collections_url, params: { collection: valid_attributes }
      }.not_to change(Collection, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /update" do
    it "lets the owner update" do
      sign_in owner
      patch collection_url(collection), params: { collection: { name: "Renamed" } }
      expect(collection.reload.name).to eq("Renamed")
    end

    it "forbids a non-owner and leaves the collection unchanged" do
      sign_in other
      patch collection_url(collection), params: { collection: { name: "hacked" } }
      expect(collection.reload.name).not_to eq("hacked")
      expect(response).to be_redirect
    end

    it "allows an admin who is not the owner" do
      sign_in admin
      patch collection_url(collection), params: { collection: { name: "By Admin" } }
      expect(collection.reload.name).to eq("By Admin")
    end
  end

  describe "DELETE /destroy" do
    it "lets the owner delete" do
      sign_in owner
      expect {
        delete collection_url(collection)
      }.to change(Collection, :count).by(-1)
    end

    it "forbids a non-owner" do
      sign_in other
      expect {
        delete collection_url(collection)
      }.not_to change(Collection, :count)
      expect(response).to be_redirect
    end
  end
end
