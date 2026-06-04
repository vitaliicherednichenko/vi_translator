require 'rails_helper'

RSpec.describe "/collections/:collection_id/cards", type: :request do
  let(:en) { create(:language) }
  let(:es) { create(:language) }
  let(:owner) { create(:user, native_language: en, preferred_language: es) }
  let(:other) { create(:user, native_language: en, preferred_language: es) }
  let(:admin) { create(:user, :admin, native_language: en, preferred_language: es) }
  let(:collection) { create(:collection, user: owner, language: en) }
  let!(:card) do
    create(:card, collection: collection, user: owner, source_language: en, target_language: es)
  end
  let(:valid_attributes)   { { front_text: "hi", back_text: "hola", source_language_id: en.id, target_language_id: es.id } }
  let(:invalid_attributes) { { front_text: "", back_text: "" } }

  describe "GET /index" do
    it "renders for everyone" do
      get collection_cards_url(collection)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders for everyone" do
      get collection_card_url(collection, card)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders for a signed-in user" do
      sign_in owner
      get new_collection_card_url(collection)
      expect(response).to be_successful
    end

    it "redirects a guest to login" do
      get new_collection_card_url(collection)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /create" do
    it "creates a card owned by the current user" do
      sign_in owner
      expect {
        post collection_cards_url(collection), params: { card: valid_attributes }
      }.to change(Card, :count).by(1)
      expect(Card.last.user).to eq(owner)
      expect(Card.last.collection).to eq(collection)
    end

    it "does not create with invalid params" do
      sign_in owner
      expect {
        post collection_cards_url(collection), params: { card: invalid_attributes }
      }.not_to change(Card, :count)
      expect(response).to have_http_status(422)
    end

    it "redirects a guest to login" do
      expect {
        post collection_cards_url(collection), params: { card: valid_attributes }
      }.not_to change(Card, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /update" do
    it "lets the owner update" do
      sign_in owner
      patch collection_card_url(collection, card), params: { card: { front_text: "changed" } }
      expect(card.reload.front_text).to eq("changed")
    end

    it "forbids a non-owner and leaves the card unchanged" do
      sign_in other
      patch collection_card_url(collection, card), params: { card: { front_text: "hacked" } }
      expect(card.reload.front_text).not_to eq("hacked")
      expect(response).to be_redirect
    end

    it "allows an admin who is not the owner" do
      sign_in admin
      patch collection_card_url(collection, card), params: { card: { front_text: "by admin" } }
      expect(card.reload.front_text).to eq("by admin")
    end
  end

  describe "DELETE /destroy" do
    it "lets the owner delete" do
      sign_in owner
      expect {
        delete collection_card_url(collection, card)
      }.to change(Card, :count).by(-1)
    end

    it "forbids a non-owner" do
      sign_in other
      expect {
        delete collection_card_url(collection, card)
      }.not_to change(Card, :count)
      expect(response).to be_redirect
    end
  end
end
