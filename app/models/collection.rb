class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :language, optional: true
  has_many :cards, dependent: :destroy

  validates :name, presence: true

  scope :by_language, ->(code) { joins(:language).where(languages: { code: code }) }


  scope :in_user_languages, ->(user) {
    ids = [ user&.native_language_id, user&.preferred_language_id ].compact
    ids.any? ? where(language_id: ids) : none
  }
end
