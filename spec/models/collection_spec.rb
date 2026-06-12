require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe ".in_user_languages" do
    let(:english)  { create(:language) }
    let(:spanish)  { create(:language) }
    let(:ukrainian) { create(:language) }

    it "returns collections in either the native or the preferred language" do
      user = create(:user, native_language: spanish, preferred_language: ukrainian)
      spanish_deck   = create(:collection, language: spanish)
      ukrainian_deck = create(:collection, language: ukrainian)
      english_deck   = create(:collection, language: english)

      result = described_class.in_user_languages(user)
      expect(result).to include(spanish_deck, ukrainian_deck)
      expect(result).not_to include(english_deck)
    end

    it "shows a collection from both directions of the language pair" do
      es_to_uk = create(:collection, language: spanish) # an "es -> uk" deck

      learning_uk = create(:user, native_language: spanish, preferred_language: ukrainian)
      learning_es = create(:user, native_language: ukrainian, preferred_language: spanish)

      expect(described_class.in_user_languages(learning_uk)).to include(es_to_uk)
      expect(described_class.in_user_languages(learning_es)).to include(es_to_uk)
    end

    it "matches the native language when no preferred language is set" do
      user = create(:user, native_language: spanish)
      expect(described_class.in_user_languages(user)).to include(create(:collection, language: spanish))
      expect(described_class.in_user_languages(user)).not_to include(create(:collection, language: english))
    end

    it "returns nothing for a nil user" do
      create(:collection, language: english)
      expect(described_class.in_user_languages(nil)).to be_empty
    end

    it "returns nothing when neither language is set" do
      create(:collection, language: english)
      expect(described_class.in_user_languages(create(:user))).to be_empty
    end
  end
end
