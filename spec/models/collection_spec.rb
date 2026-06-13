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

    it "excludes a deck whose cards target a language outside the pair" do
      # es/uk learner should NOT see a "uk -> en" deck even though its language is uk
      user = create(:user, native_language: ukrainian, preferred_language: spanish)

      es_uk = create(:collection, language: spanish)
      create(:card, collection: es_uk, source_language: spanish, target_language: ukrainian)

      uk_en = create(:collection, language: ukrainian)
      create(:card, collection: uk_en, source_language: ukrainian, target_language: english)

      result = described_class.in_user_languages(user)
      expect(result).to include(es_uk)
      expect(result).not_to include(uk_en)
    end

    it "shows a uk -> en deck only when the pair is uk and en" do
      uk_en = create(:collection, language: ukrainian)
      create(:card, collection: uk_en, source_language: ukrainian, target_language: english)

      learner = create(:user, native_language: ukrainian, preferred_language: english)
      expect(described_class.in_user_languages(learner)).to include(uk_en)
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
