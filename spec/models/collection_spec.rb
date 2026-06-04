require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe ".in_user_native_language" do
    let(:english) { create(:language) }
    let(:french)  { create(:language) }
    let(:user)    { create(:user, native_language: english) }

    it "returns only collections in the user's native language" do
      match    = create(:collection, language: english)
      no_match = create(:collection, language: french)

      result = described_class.in_user_native_language(user)
      expect(result).to include(match)
      expect(result).not_to include(no_match)
    end

    it "returns nothing for a nil user" do
      create(:collection, language: english)
      expect(described_class.in_user_native_language(nil)).to be_empty
    end

    it "returns nothing when the native language isn't set" do
      create(:collection, language: english)
      expect(described_class.in_user_native_language(create(:user))).to be_empty
    end
  end
end
