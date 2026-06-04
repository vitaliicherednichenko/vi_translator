require 'rails_helper'

RSpec.describe CardPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:other) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:card) { create(:card, user: owner) }

  permissions :index?, :show? do
    it "is open to everyone, including signed-out visitors" do
      expect(subject).to permit(nil, card)
      expect(subject).to permit(other, card)
      expect(subject).to permit(owner, card)
    end
  end

  permissions :create?, :new? do
    it "permits any signed-in user" do
      expect(subject).to permit(owner, Card.new)
    end

    it "denies signed-out visitors" do
      expect(subject).not_to permit(nil, Card.new)
    end
  end

  permissions :update?, :edit?, :destroy? do
    it "permits the owner" do
      expect(subject).to permit(owner, card)
    end

    it "permits an admin who is not the owner" do
      expect(subject).to permit(admin, card)
    end

    it "denies other (non-admin) signed-in users" do
      expect(subject).not_to permit(other, card)
    end

    it "denies signed-out visitors" do
      expect(subject).not_to permit(nil, card)
    end
  end

  describe "Scope" do
    it "returns every card for any user" do
      mine = create(:card, user: owner)
      theirs = create(:card, user: other)

      expect(CardPolicy::Scope.new(owner, Card).resolve).to include(mine, theirs)
      expect(CardPolicy::Scope.new(nil, Card).resolve).to include(mine, theirs)
    end
  end
end
