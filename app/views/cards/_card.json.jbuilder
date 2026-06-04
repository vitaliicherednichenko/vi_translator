json.extract! card, :id, :front_text, :back_text, :user_id, :collection_id, :source_language_id, :target_language_id, :created_at, :updated_at
json.url card_url(card, format: :json)
