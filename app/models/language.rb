class Language < ApplicationRecord
  has_many :cards_as_source, class_name: "Card", foreign_key: "source_language_id", dependent: :nullify
  has_many :cards_as_target, class_name: "Card", foreign_key: "target_language_id", dependent: :nullify
  has_many :collections, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { is: 2 }
end
