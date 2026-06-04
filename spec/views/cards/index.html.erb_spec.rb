require 'rails_helper'

RSpec.describe "cards/index", type: :view do
  before(:each) do
    assign(:cards, [
      Card.create!(
        front_text: "MyText",
        back_text: "MyText",
        user: nil,
        collection: nil,
        source_language: nil,
        target_language: nil
      ),
      Card.create!(
        front_text: "MyText",
        back_text: "MyText",
        user: nil,
        collection: nil,
        source_language: nil,
        target_language: nil
      )
    ])
  end

  it "renders a list of cards" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
