require 'rails_helper'

RSpec.describe Card, type: :model do
  describe ".between_user_languages" do
    let(:english) { create(:language) }
    let(:spanish) { create(:language) }
    let(:french)  { create(:language) }
    let(:user)    { create(:user, native_language: english, preferred_language: spanish) }

    it "returns cards translating between native and preferred in either direction" do
      forward = create(:card, source_language: english, target_language: spanish)
      reverse = create(:card, source_language: spanish, target_language: english)
      other   = create(:card, source_language: english, target_language: french)

      result = described_class.between_user_languages(user)
      expect(result).to include(forward, reverse)
      expect(result).not_to include(other)
    end

    it "returns nothing for a nil user" do
      create(:card, source_language: english, target_language: spanish)
      expect(described_class.between_user_languages(nil)).to be_empty
    end

    it "returns nothing when either language isn't set" do
      create(:card, source_language: english, target_language: spanish)
      only_native = create(:user, native_language: english)
      expect(described_class.between_user_languages(only_native)).to be_empty
    end
  end
end
