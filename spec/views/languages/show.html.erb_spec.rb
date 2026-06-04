require 'rails_helper'

RSpec.describe "languages/show", type: :view do
  before(:each) do
    assign(:language, Language.create!(
      name: "Name",
      code: "Code",
      native_name: "Native Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/Native Name/)
  end
end
