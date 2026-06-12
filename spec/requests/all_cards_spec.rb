require 'rails_helper'

RSpec.describe "All cards pages", type: :request do
  let(:en) { create(:language) }
  let(:es) { create(:language) }
  let(:user) { create(:user, native_language: en, preferred_language: es) }

  describe "GET /cards (index)" do
    it "is accessible to everyone" do
      get cards_url
      expect(response).to be_successful
    end

    it "offers collections in either of the user's languages in the Add-to menu" do
      fr = create(:language)
      create(:collection, user: user, language: en, name: "native-set")     # native (en)
      create(:collection, user: user, language: es, name: "preferred-set")   # preferred (es)
      create(:collection, user: user, language: fr, name: "unrelated-set")   # neither

      sign_in user # native_language: en, preferred_language: es
      get cards_url

      expect(response.body).to include("native-set")
      expect(response.body).to include("preferred-set")
      expect(response.body).not_to include("unrelated-set")
    end

    it "still shows a card after it has been removed (soft-deleted)" do
      collection = create(:collection, user: user, language: en)
      card = create(:card, user: user, collection: collection,
                    front_text: "stays-in-all-cards", source_language: en, target_language: es)
      card.soft_delete!

      sign_in user
      get cards_url

      expect(response.body).to include("stays-in-all-cards")
    end
  end

  describe "GET /cards/deleted" do
    it "redirects a guest to login" do
      get deleted_cards_url
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lists only the current user's deleted cards" do
      collection = create(:collection, user: user, language: en)
      create(:card, user: user, collection: collection, front_text: "mine-deleted",
                    source_language: en, target_language: es, deleted_at: Time.current)
      create(:card, user: user, collection: collection, front_text: "mine-kept",
                    source_language: en, target_language: es)
      create(:card, front_text: "others-deleted", deleted_at: Time.current)

      sign_in user
      get deleted_cards_url

      expect(response).to be_successful
      expect(response.body).to include("mine-deleted")
      expect(response.body).not_to include("mine-kept")
      expect(response.body).not_to include("others-deleted")
    end
  end

  describe "GET /cards/export" do
    it "redirects a guest to login" do
      get export_cards_url
      expect(response).to redirect_to(new_user_session_path)
    end

    it "exports only the current user's active cards as CSV" do
      collection = create(:collection, user: user, language: en)
      create(:card, user: user, collection: collection, front_text: "hello", back_text: "hola",
                    source_language: en, target_language: es)
      create(:card, user: user, collection: collection, front_text: "trashed", back_text: "x",
                    source_language: en, target_language: es, deleted_at: Time.current)
      create(:card, front_text: "not-mine", back_text: "y")

      sign_in user
      get export_cards_url

      expect(response).to be_successful
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.body).to include("front_text,back_text") # header row
      expect(response.body).to include("hello").and include("hola")
      expect(response.body).not_to include("trashed")  # soft-deleted excluded
      expect(response.body).not_to include("not-mine") # another user's card excluded
    end
  end

  describe "deleting from All Cards" do
    it "soft-deletes for a regular owner (card stays in All Cards)" do
      collection = create(:collection, user: user, language: en)
      card = create(:card, user: user, collection: collection,
                    front_text: "soft-me", source_language: en, target_language: es)

      sign_in user
      delete collection_card_path(collection, card)

      expect(Card.exists?(card.id)).to be(true)
      expect(card.reload.deleted?).to be(true)
    end

    it "lets an admin permanently destroy a card so it leaves All Cards" do
      admin = create(:user, :admin, native_language: en, preferred_language: es)
      owner = create(:user)
      collection = create(:collection, user: owner, language: en)
      card = create(:card, user: owner, collection: collection,
                    front_text: "destroy-me", source_language: en, target_language: es)

      sign_in admin
      delete collection_card_path(collection, card), params: { hard: true }

      expect(Card.exists?(card.id)).to be(false)

      get cards_url
      expect(response.body).not_to include("destroy-me")
    end

    it "ignores the hard flag for a non-admin (still a soft delete)" do
      collection = create(:collection, user: user, language: en)
      card = create(:card, user: user, collection: collection,
                    front_text: "still-here", source_language: en, target_language: es)

      sign_in user
      delete collection_card_path(collection, card), params: { hard: true }

      expect(Card.exists?(card.id)).to be(true)
      expect(card.reload.deleted?).to be(true)
    end
  end

  describe "POST /cards/:id/add_to_collection" do
    it "redirects a guest to login" do
      card = create(:card)
      post add_card_to_collection_url(card), params: { collection_id: 1 }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "copies another user's card into the current user's collection" do
      other = create(:user)
      other_collection = create(:collection, user: other, language: en)
      source = create(:card, user: other, collection: other_collection,
                      front_text: "borrow-me", back_text: "prestame",
                      source_language: en, target_language: es)
      my_collection = create(:collection, user: user, language: en)

      sign_in user
      expect {
        post add_card_to_collection_url(source), params: { collection_id: my_collection.id }
      }.to change { user.cards.count }.by(1)

      copied = my_collection.cards.last
      expect(copied.front_text).to eq("borrow-me")
      expect(copied.back_text).to eq("prestame")
      expect(copied.user).to eq(user)
      expect(copied.copied_from).to eq(source)
    end

    it "does not show the copied card again on the All Cards page" do
      source = create(:card, front_text: "once-only", back_text: "solo-una",
                      source_language: en, target_language: es)
      my_collection = create(:collection, user: user, language: en)

      sign_in user
      post add_card_to_collection_url(source), params: { collection_id: my_collection.id }
      copy = my_collection.cards.last
      get cards_url

      expect(response.body).to include(ActionView::RecordIdentifier.dom_id(source))
      expect(response.body).not_to include(ActionView::RecordIdentifier.dom_id(copy))
    end

    it "does not duplicate a card already in the collection" do
      source = create(:card, front_text: "dup", back_text: "dup-back")
      my_collection = create(:collection, user: user, language: en)

      sign_in user
      post add_card_to_collection_url(source), params: { collection_id: my_collection.id }
      expect {
        post add_card_to_collection_url(source), params: { collection_id: my_collection.id }
      }.not_to change { user.cards.count }
    end

    it "does not let a user add into someone else's collection" do
      source = create(:card, front_text: "x", back_text: "y")
      foreign_collection = create(:collection)

      sign_in user
      expect {
        post add_card_to_collection_url(source), params: { collection_id: foreign_collection.id }
      }.not_to change { Card.count }
      expect(flash[:alert]).to be_present
    end
  end

  describe "card import" do
    def csv_upload(content)
      file = Tempfile.new([ "cards", ".csv" ])
      file.write(content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, "text/csv")
    end

    describe "GET /cards/import" do
      it "redirects a guest to login" do
        get import_cards_url
        expect(response).to redirect_to(new_user_session_path)
      end

      it "renders the form for a signed-in user" do
        sign_in user
        get import_cards_url
        expect(response).to be_successful
      end
    end

    describe "POST /cards/import" do
      it "redirects a guest to login" do
        post import_cards_url, params: { file: csv_upload("collection,front_text\n") }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "imports cards for the current user and creates missing collections" do
        csv = <<~CSV
          collection,front_text,back_text,source_language,target_language,created_at
          Imported Set,hello,hola,#{en.name},#{es.name},2026-01-01T00:00:00Z
          Imported Set,dog,perro,#{en.code},#{es.code},2026-01-01T00:00:00Z
        CSV

        sign_in user
        expect {
          post import_cards_url, params: { file: csv_upload(csv) }
        }.to change { user.cards.count }.by(2)

        collection = user.collections.find_by(name: "Imported Set")
        expect(collection).to be_present
        expect(collection.cards.pluck(:front_text)).to contain_exactly("hello", "dog")
      end

      it "skips rows with blank text or an unknown language" do
        csv = <<~CSV
          collection,front_text,back_text,source_language,target_language
          Set,ok,bien,#{en.name},#{es.name}
          Set,,blankfront,#{en.name},#{es.name}
          Set,bad,lang,Klingon,#{es.name}
        CSV

        sign_in user
        expect {
          post import_cards_url, params: { file: csv_upload(csv) }
        }.to change { user.cards.count }.by(1)
      end

      it "does not create duplicate cards when the same file is imported twice" do
        csv = <<~CSV
          collection,front_text,back_text,source_language,target_language
          Imported Set,hello,hola,#{en.name},#{es.name}
          Imported Set,dog,perro,#{en.name},#{es.name}
        CSV

        sign_in user
        post import_cards_url, params: { file: csv_upload(csv) }
        expect(user.cards.count).to eq(2)

        expect {
          post import_cards_url, params: { file: csv_upload(csv) }
        }.not_to change { user.cards.count }
      end

      it "shows an alert when no file is given" do
        sign_in user
        post import_cards_url
        expect(response).to redirect_to(import_cards_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
