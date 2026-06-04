class Card < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  belongs_to :source_language, class_name: "Language", optional: true
  belongs_to :target_language, class_name: "Language", optional: true

  validates :front_text, presence: true
  validates :back_text, presence: true

  def translation_pair
    "#{source_language&.code} → #{target_language&.code}"
  end
end
