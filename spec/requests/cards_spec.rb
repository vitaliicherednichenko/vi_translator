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

  describe "DELETE /collections/:collection_id/cards/bulk" do
    it "redirects a guest to login" do
      delete bulk_collection_cards_url(collection), params: { card_ids: [ card.id ] }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "soft-deletes the selected cards for the owner" do
      a = create(:card, collection: collection, user: owner, source_language: en, target_language: es)
      b = create(:card, collection: collection, user: owner, source_language: en, target_language: es)
      keep = create(:card, collection: collection, user: owner, source_language: en, target_language: es)

      sign_in owner
      delete bulk_collection_cards_url(collection), params: { card_ids: [ a.id, b.id ] }

      expect(a.reload.deleted?).to be(true)
      expect(b.reload.deleted?).to be(true)
      expect(keep.reload.deleted?).to be(false)
      expect(response).to redirect_to(collection_cards_path(collection))
    end

    it "does not touch cards from other collections" do
      other_collection = create(:collection, user: owner, language: en)
      foreign = create(:card, collection: other_collection, user: owner, source_language: en, target_language: es)

      sign_in owner
      delete bulk_collection_cards_url(collection), params: { card_ids: [ foreign.id ] }

      expect(foreign.reload.deleted?).to be(false)
    end

    it "forbids a non-owner from bulk-deleting" do
      sign_in other
      delete bulk_collection_cards_url(collection), params: { card_ids: [ card.id ] }

      expect(card.reload.deleted?).to be(false)
      expect(flash[:alert]).to be_present
    end
  end

  describe "GET /collections/:collection_id/cards/export" do
    it "redirects a guest to login" do
      get export_collection_cards_url(collection)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "exports only this collection's kept cards as CSV" do
      create(:card, collection: collection, user: owner, front_text: "keep", back_text: "manten",
                    source_language: en, target_language: es)
      create(:card, collection: collection, user: owner, front_text: "trashed", back_text: "x",
                    source_language: en, target_language: es, deleted_at: Time.current)
      other_collection = create(:collection, user: owner, language: en)
      create(:card, collection: other_collection, user: owner, front_text: "elsewhere", back_text: "y",
                    source_language: en, target_language: es)

      sign_in owner
      get export_collection_cards_url(collection)

      expect(response.media_type).to eq("text/csv")
      expect(response.body).to include("keep")
      expect(response.body).not_to include("trashed")    # soft-deleted excluded
      expect(response.body).not_to include("elsewhere")  # other collection excluded
    end
  end

  describe "card import into a collection" do
    def csv_upload(content)
      file = Tempfile.new([ "cards", ".csv" ])
      file.write(content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, "text/csv")
    end

    let(:csv) do
      <<~CSV
        front_text,back_text,source_language,target_language
        hello,hola,#{en.name},#{es.name}
        dog,perro,#{en.code},#{es.code}
      CSV
    end

    it "redirects a guest to login" do
      get import_collection_cards_url(collection)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "forbids importing into a collection you don't own" do
      sign_in other
      post import_collection_cards_url(collection), params: { file: csv_upload(csv) }
      expect(response).to redirect_to(root_path).or have_http_status(:found)
      expect(collection.cards.where(front_text: "hello")).to be_empty
    end

    it "imports every row into this collection for the owner" do
      sign_in owner
      expect {
        post import_collection_cards_url(collection), params: { file: csv_upload(csv) }
      }.to change { collection.cards.count }.by(2)

      expect(collection.cards.pluck(:front_text)).to include("hello", "dog")
    end

    it "ignores the CSV collection column and uses this collection" do
      csv_with_other = <<~CSV
        collection,front_text,back_text,source_language,target_language
        Some Other Name,bird,pajaro,#{en.name},#{es.name}
      CSV

      sign_in owner
      post import_collection_cards_url(collection), params: { file: csv_upload(csv_with_other) }

      expect(collection.cards.pluck(:front_text)).to include("bird")
      expect(Collection.where(name: "Some Other Name")).to be_empty
    end

    it "shows an alert when no file is given" do
      sign_in owner
      post import_collection_cards_url(collection)
      expect(response).to redirect_to(import_collection_cards_path(collection))
      expect(flash[:alert]).to be_present
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
    it "soft-deletes for the owner (record kept, dropped from listings)" do
      sign_in owner
      expect {
        delete collection_card_url(collection, card)
      }.to change { Card.kept.count }.by(-1)
      expect(Card.exists?(card.id)).to be(true)
      expect(card.reload.deleted_at).to be_present
    end

    it "forbids a non-owner and does not delete" do
      sign_in other
      delete collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_nil
      expect(response).to be_redirect
    end

    it "keeps a first delete of a kept card a soft delete even with the hard flag" do
      sign_in owner
      delete collection_card_url(collection, card), params: { hard: true }
      expect(Card.exists?(card.id)).to be(true)
      expect(card.reload.deleted?).to be(true)
    end

    it "lets the owner permanently delete their own card once it is soft-deleted" do
      card.soft_delete!
      sign_in owner
      delete collection_card_url(collection, card), params: { hard: true }
      expect(Card.exists?(card.id)).to be(false)
    end

    it "forbids a non-owner from permanently deleting a soft-deleted card" do
      card.soft_delete!
      sign_in other
      delete collection_card_url(collection, card), params: { hard: true }
      expect(Card.exists?(card.id)).to be(true)
    end

    it "lets an admin (non-owner) soft-delete" do
      sign_in admin
      delete collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_present
    end
  end

  describe "PATCH /restore" do
    before { card.soft_delete! }

    it "lets the owner restore" do
      sign_in owner
      patch restore_collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_nil
    end

    it "lets an admin (non-owner) restore" do
      sign_in admin
      patch restore_collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_nil
    end

    it "forbids a non-owner and keeps it deleted" do
      sign_in other
      patch restore_collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_present
      expect(response).to be_redirect
    end

    it "redirects a guest to login" do
      patch restore_collection_card_url(collection, card)
      expect(card.reload.deleted_at).to be_present
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
