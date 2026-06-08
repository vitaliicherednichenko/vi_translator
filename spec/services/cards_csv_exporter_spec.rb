require 'rails_helper'
require 'csv'

RSpec.describe CardsCsvExporter do
  let(:en) { create(:language) }
  let(:es) { create(:language) }
  let(:user) { create(:user, native_language: en, preferred_language: es) }
  let(:collection) { create(:collection, user: user, language: en) }

  it "returns CSV with a header row and the user's active cards" do
    create(:card, user: user, collection: collection, front_text: "hello", back_text: "hola",
                  source_language: en, target_language: es)

    csv = CSV.parse(described_class.new(user).call, headers: true)

    expect(csv.headers).to eq(%w[collection front_text back_text source_language target_language created_at])
    expect(csv.size).to eq(1)
    row = csv.first
    expect(row["front_text"]).to eq("hello")
    expect(row["back_text"]).to eq("hola")
    expect(row["collection"]).to eq(collection.name)
    expect(row["source_language"]).to eq(en.name)
  end

  it "excludes soft-deleted cards and other users' cards" do
    create(:card, user: user, collection: collection, front_text: "kept",
                  source_language: en, target_language: es)
    create(:card, user: user, collection: collection, front_text: "trashed",
                  source_language: en, target_language: es, deleted_at: Time.current)
    create(:card, front_text: "not-mine")

    body = described_class.new(user).call

    expect(body).to include("kept")
    expect(body).not_to include("trashed")
    expect(body).not_to include("not-mine")
  end
end
