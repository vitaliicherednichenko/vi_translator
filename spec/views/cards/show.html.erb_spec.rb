require 'rails_helper'

RSpec.describe "cards/show", type: :view do
  before(:each) do
    assign(:card, Card.create!(
      front_text: "MyText",
      back_text: "MyText",
      user: nil,
      collection: nil,
      source_language: nil,
      target_language: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
