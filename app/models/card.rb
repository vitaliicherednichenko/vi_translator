class Card < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  belongs_to :source_language, class_name: "Language", optional: true
  belongs_to :target_language, class_name: "Language", optional: true
  belongs_to :copied_from, class_name: "Card", optional: true

  validates :front_text, presence: true
  validates :back_text, presence: true

  scope :kept,     -> { where(deleted_at: nil) }
  scope :deleted,  -> { where.not(deleted_at: nil) }
  scope :original, -> { where(copied_from_id: nil) }

  scope :search, ->(query) {
    q = query.to_s.strip
    next all if q.blank?

    where("front_text ILIKE :q OR back_text ILIKE :q", q: "%#{sanitize_sql_like(q)}%")
  }

  scope :between_user_languages, ->(user) {
    native = user&.native_language_id
    preferred = user&.preferred_language_id
    next none unless native && preferred

    where(source_language_id: native, target_language_id: preferred)
      .or(where(source_language_id: preferred, target_language_id: native))
  }

  def translation_pair
    "#{source_language&.code} → #{target_language&.code}"
  end

  def deleted?
    deleted_at.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil)
  end
end
