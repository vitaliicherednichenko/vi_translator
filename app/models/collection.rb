class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :language, optional: true
  has_many :cards, dependent: :destroy

  validates :name, presence: true

  scope :by_language, ->(code) { joins(:language).where(languages: { code: code }) }

  scope :in_user_native_language, ->(user) {
    language = user&.native_language
    language ? where(language_id: language.id) : none
  }
end
