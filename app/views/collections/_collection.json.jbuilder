json.extract! collection, :id, :name, :description, :user_id, :language_id, :created_at, :updated_at
json.url collection_url(collection, format: :json)
