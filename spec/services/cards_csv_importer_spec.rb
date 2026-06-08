require 'rails_helper'

RSpec.describe CardsCsvImporter do
  let(:en) { create(:language) }
  let(:es) { create(:language) }
  let(:user) { create(:user, native_language: en, preferred_language: es) }

  def import(content)
    described_class.new(user, StringIO.new(content)).call
  end

  it "creates cards and missing collections owned by the user" do
    csv = <<~CSV
      collection,front_text,back_text,source_language,target_language
      Imported Set,hello,hola,#{en.name},#{es.name}
      Imported Set,dog,perro,#{en.code},#{es.code}
    CSV

    result = nil
    expect { result = import(csv) }.to change { user.cards.count }.by(2)

    expect(result).to be_success
    expect(result.imported).to eq(2)
    expect(result.skipped).to eq(0)
    expect(user.collections.find_by(name: "Imported Set")).to be_present
  end

  it "skips rows with blank text or an unknown language" do
    csv = <<~CSV
      collection,front_text,back_text,source_language,target_language
      Set,ok,bien,#{en.name},#{es.name}
      Set,,blankfront,#{en.name},#{es.name}
      Set,bad,lang,Klingon,#{es.name}
    CSV

    result = import(csv)

    expect(result.imported).to eq(1)
    expect(result.skipped).to eq(2)
  end

  it "does not duplicate identical cards on re-import" do
    csv = <<~CSV
      collection,front_text,back_text,source_language,target_language
      Set,hello,hola,#{en.name},#{es.name}
    CSV

    import(csv)
    expect { import(csv) }.not_to change { user.cards.count }
  end

  it "reports an error for malformed CSV" do
    result = import("a,b,c\n\"unterminated")

    expect(result).not_to be_success
    expect(result.error).to be_present
  end

  it "summary describes imported and skipped counts" do
    result = described_class::Result.new(imported: 2, skipped: 1)
    expect(result.summary).to eq("Imported 2 cards. Skipped 1 row.")
  end
end
