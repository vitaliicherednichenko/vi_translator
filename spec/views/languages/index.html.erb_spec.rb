require 'rails_helper'

RSpec.describe "languages/index", type: :view do
  before(:each) do
    assign(:languages, [
      Language.create!(
        name: "Name",
        code: "Code",
        native_name: "Native Name"
      ),
      Language.create!(
        name: "Name",
        code: "Code",
        native_name: "Native Name"
      )
    ])
  end

  it "renders a list of languages" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Code".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Native Name".to_s), count: 2
  end
end
