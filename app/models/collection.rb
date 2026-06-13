class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :language, optional: true
  has_many :cards, dependent: :destroy

  validates :name, presence: true

  scope :by_language, ->(code) { joins(:language).where(languages: { code: code }) }

  scope :search, ->(query) {
    q = query.to_s.strip
    next all if q.blank?

    where("name ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(q)}%")
  }

  scope :in_user_languages, ->(user) {
    ids = [ user&.native_language_id, user&.preferred_language_id ].compact
    next none if ids.empty?

    pair_cards = Card.kept
                     .where(source_language_id: ids, target_language_id: ids)
                     .where("cards.collection_id = collections.id")
                     .select("1").to_sql
    any_cards = Card.kept
                    .where("cards.collection_id = collections.id")
                    .select("1").to_sql

    where(language_id: ids)
      .where("EXISTS (#{pair_cards}) OR NOT EXISTS (#{any_cards})")
  }
end
