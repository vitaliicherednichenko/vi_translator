require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "defaults admin to false" do
    expect(create(:user).admin).to be(false)
  end

  it "is an admin with the :admin trait" do
    expect(create(:user, :admin).admin).to be(true)
  end

  it "destroys its collections and cards when destroyed" do
    user = create(:user)
    collection = create(:collection, user: user)
    create(:card, user: user, collection: collection)

    expect { user.destroy }
      .to change(Collection, :count).by(-1)
      .and change(Card, :count).by(-1)
  end
end
