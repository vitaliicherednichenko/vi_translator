require "rails_helper"

RSpec.describe CardsController, type: :routing do
  describe "nested routing under collections" do
    it "routes to #index" do
      expect(get: "/collections/1/cards").to route_to("cards#index", collection_id: "1")
    end

    it "routes to #new" do
      expect(get: "/collections/1/cards/new").to route_to("cards#new", collection_id: "1")
    end

    it "routes to #show" do
      expect(get: "/collections/1/cards/2").to route_to("cards#show", collection_id: "1", id: "2")
    end

    it "routes to #edit" do
      expect(get: "/collections/1/cards/2/edit").to route_to("cards#edit", collection_id: "1", id: "2")
    end

    it "routes to #create" do
      expect(post: "/collections/1/cards").to route_to("cards#create", collection_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/collections/1/cards/2").to route_to("cards#update", collection_id: "1", id: "2")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/collections/1/cards/2").to route_to("cards#update", collection_id: "1", id: "2")
    end

    it "routes to #destroy" do
      expect(delete: "/collections/1/cards/2").to route_to("cards#destroy", collection_id: "1", id: "2")
    end
  end

  describe "top-level cards list" do
    it "routes GET /cards to all_cards#index" do
      expect(get: "/cards").to route_to("all_cards#index")
    end
  end
end
