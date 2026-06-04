class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :language, optional: true
  has_many :cards, dependent: :destroy

  validates :name, presence: true

  scope :by_language, ->(code) { joins(:language).where(languages: { code: code }) }
end
