require 'rails_helper'

RSpec.describe "collections/show", type: :view do
  before(:each) do
    assign(:collection, Collection.create!(
      name: "Name",
      description: "Description",
      user: nil,
      language: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
