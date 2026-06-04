require 'rails_helper'

RSpec.describe "cards/new", type: :view do
  before(:each) do
    assign(:card, Card.new(
      front_text: "MyText",
      back_text: "MyText",
      user: nil,
      collection: nil,
      source_language: nil,
      target_language: nil
    ))
  end

  it "renders new card form" do
    render

    assert_select "form[action=?][method=?]", cards_path, "post" do

      assert_select "textarea[name=?]", "card[front_text]"

      assert_select "textarea[name=?]", "card[back_text]"

      assert_select "input[name=?]", "card[user_id]"

      assert_select "input[name=?]", "card[collection_id]"

      assert_select "input[name=?]", "card[source_language_id]"

      assert_select "input[name=?]", "card[target_language_id]"
    end
  end
end
