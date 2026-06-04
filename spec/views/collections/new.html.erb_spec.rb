require 'rails_helper'

RSpec.describe "collections/new", type: :view do
  before(:each) do
    assign(:collection, Collection.new(
      name: "MyString",
      description: "MyString",
      user: nil,
      language: nil
    ))
  end

  it "renders new collection form" do
    render

    assert_select "form[action=?][method=?]", collections_path, "post" do

      assert_select "input[name=?]", "collection[name]"

      assert_select "input[name=?]", "collection[description]"

      assert_select "input[name=?]", "collection[user_id]"

      assert_select "input[name=?]", "collection[language_id]"
    end
  end
end
