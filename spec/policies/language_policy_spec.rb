require 'rails_helper'

RSpec.describe LanguagePolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user) }
  let(:language) { create(:language) }

  permissions :index?, :show? do
    it "is open to everyone, including signed-out visitors" do
      expect(subject).to permit(nil, language)
      expect(subject).to permit(member, language)
      expect(subject).to permit(admin, language)
    end
  end

  permissions :create?, :new?, :update?, :edit?, :destroy? do
    it "permits admins" do
      expect(subject).to permit(admin, language)
    end

    it "denies non-admin signed-in users" do
      expect(subject).not_to permit(member, language)
    end

    it "denies signed-out visitors" do
      expect(subject).not_to permit(nil, language)
    end
  end

  describe "Scope" do
    it "returns every language for any user" do
      a = create(:language)
      b = create(:language)

      expect(LanguagePolicy::Scope.new(member, Language).resolve).to include(a, b)
      expect(LanguagePolicy::Scope.new(nil, Language).resolve).to include(a, b)
    end
  end
end
