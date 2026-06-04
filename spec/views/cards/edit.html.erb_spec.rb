require 'rails_helper'

RSpec.describe "cards/edit", type: :view do
  let(:card) {
    Card.create!(
      front_text: "MyText",
      back_text: "MyText",
      user: nil,
      collection: nil,
      source_language: nil,
      target_language: nil
    )
  }

  before(:each) do
    assign(:card, card)
  end

  it "renders the edit card form" do
    render

    assert_select "form[action=?][method=?]", card_path(card), "post" do

      assert_select "textarea[name=?]", "card[front_text]"

      assert_select "textarea[name=?]", "card[back_text]"

      assert_select "input[name=?]", "card[user_id]"

      assert_select "input[name=?]", "card[collection_id]"

      assert_select "input[name=?]", "card[source_language_id]"

      assert_select "input[name=?]", "card[target_language_id]"
    end
  end
end
