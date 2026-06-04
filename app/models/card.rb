class Card < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  belongs_to :source_language, class_name: "Language", optional: true
  belongs_to :target_language, class_name: "Language", optional: true

  validates :front_text, presence: true
  validates :back_text, presence: true

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
end
