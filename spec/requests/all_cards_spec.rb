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
