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
end
