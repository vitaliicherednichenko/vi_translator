require 'rails_helper'

RSpec.describe CollectionPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:other) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:collection) { create(:collection, user: owner) }

  permissions :index?, :show? do
    it "is open to everyone, including signed-out visitors" do
      expect(subject).to permit(nil, collection)
      expect(subject).to permit(other, collection)
      expect(subject).to permit(owner, collection)
    end
  end

  permissions :create?, :new? do
    it "permits any signed-in user" do
      expect(subject).to permit(owner, Collection.new)
    end

    it "denies signed-out visitors" do
      expect(subject).not_to permit(nil, Collection.new)
    end
  end

  permissions :update?, :edit?, :destroy? do
    it "permits the owner" do
      expect(subject).to permit(owner, collection)
    end

    it "permits an admin who is not the owner" do
      expect(subject).to permit(admin, collection)
    end

    it "denies other (non-admin) signed-in users" do
      expect(subject).not_to permit(other, collection)
    end

    it "denies signed-out visitors" do
      expect(subject).not_to permit(nil, collection)
    end
  end

  describe "Scope" do
    it "returns every collection for any user" do
      mine = create(:collection, user: owner)
      theirs = create(:collection, user: other)

      expect(CollectionPolicy::Scope.new(owner, Collection).resolve).to include(mine, theirs)
      expect(CollectionPolicy::Scope.new(nil, Collection).resolve).to include(mine, theirs)
    end
  end
end
