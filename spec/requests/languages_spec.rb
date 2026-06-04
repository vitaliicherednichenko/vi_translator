require 'rails_helper'

RSpec.describe "/languages", type: :request do
  let(:admin)    { create(:user, :admin) }
  let(:member)   { create(:user) }
  let(:language) { create(:language) }
  let(:valid_attributes)   { { name: "Klingon", code: "tl", native_name: "tlhIngan" } }
  let(:invalid_attributes) { { name: "", code: "toolong", native_name: "" } }

  describe "GET /index" do
    it "is open to signed-out visitors" do
      language
      get languages_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "is open to signed-out visitors" do
      get language_url(language)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders for an admin" do
      sign_in admin
      get new_language_url
      expect(response).to be_successful
    end

    it "redirects a non-admin" do
      sign_in member
      get new_language_url
      expect(response).to be_redirect
    end

    it "redirects a signed-out visitor to login" do
      get new_language_url
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /create" do
    context "as an admin" do
      before { sign_in admin }

      it "creates a language with valid params" do
        expect {
          post languages_url, params: { language: valid_attributes }
        }.to change(Language, :count).by(1)
        expect(response).to redirect_to(language_url(Language.last))
      end

      it "does not create with invalid params" do
        expect {
          post languages_url, params: { language: invalid_attributes }
        }.not_to change(Language, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "as a non-admin" do
      it "is forbidden and creates nothing" do
        sign_in member
        expect {
          post languages_url, params: { language: valid_attributes }
        }.not_to change(Language, :count)
        expect(response).to be_redirect
      end
    end
  end

  describe "PATCH /update" do
    it "lets an admin update" do
      sign_in admin
      patch language_url(language), params: { language: { name: "Renamed" } }
      expect(language.reload.name).to eq("Renamed")
    end

    it "forbids a non-admin and leaves the record unchanged" do
      sign_in member
      original = language.name
      patch language_url(language), params: { language: { name: "Hacked" } }
      expect(language.reload.name).to eq(original)
      expect(response).to be_redirect
    end
  end

  describe "DELETE /destroy" do
    it "lets an admin delete" do
      sign_in admin
      language
      expect {
        delete language_url(language)
      }.to change(Language, :count).by(-1)
    end

    it "forbids a non-admin and keeps the record" do
      sign_in member
      language
      expect {
        delete language_url(language)
      }.not_to change(Language, :count)
      expect(response).to be_redirect
    end
  end
end
