require 'rails_helper'

RSpec.describe Language, type: :model do
  it "has a valid factory" do
    expect(build(:language)).to be_valid
  end

  it "requires a name" do
    expect(build(:language, name: nil)).not_to be_valid
  end

  it "requires a code of exactly two characters" do
    expect(build(:language, code: "a")).not_to be_valid
    expect(build(:language, code: "abc")).not_to be_valid
  end

  it "requires a unique code" do
    existing = create(:language)
    expect(build(:language, code: existing.code)).not_to be_valid
  end

  it "requires a unique name" do
    existing = create(:language)
    expect(build(:language, name: existing.name)).not_to be_valid
  end
end
