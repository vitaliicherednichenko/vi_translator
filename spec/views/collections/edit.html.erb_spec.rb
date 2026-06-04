require 'rails_helper'

RSpec.describe "collections/edit", type: :view do
  let(:collection) {
    Collection.create!(
      name: "MyString",
      description: "MyString",
      user: nil,
      language: nil
    )
  }

  before(:each) do
    assign(:collection, collection)
  end

  it "renders the edit collection form" do
    render

    assert_select "form[action=?][method=?]", collection_path(collection), "post" do

      assert_select "input[name=?]", "collection[name]"

      assert_select "input[name=?]", "collection[description]"

      assert_select "input[name=?]", "collection[user_id]"

      assert_select "input[name=?]", "collection[language_id]"
    end
  end
end
